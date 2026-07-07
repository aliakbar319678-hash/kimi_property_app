/**
 * releaseHeldPayments.ts
 * ──────────────────────
 * Hourly cron worker that atomically releases vendor payments whose
 * hold_release_date has passed.
 *
 * Idempotency mechanism:
 *  1. SELECT … FOR UPDATE SKIP LOCKED  → only one worker grabs each row
 *  2. UPDATE … WHERE hold_status='holding' RETURNING *  → second check ensures
 *     no double-release even if two workers somehow race past step 1
 */

import { pool } from '../db';
import { NotificationService } from '../services/notification.service';

export async function releaseHeldPayments(): Promise<void> {
  const client = await pool.connect();
  console.log('[releaseHeldPayments] Starting run at', new Date().toISOString());
  let releasedCount = 0;

  try {
    await client.query('BEGIN');

    // 1. Lock eligible rows exclusively; skip any already locked by a parallel worker
    const candidates = await client.query(`
      SELECT id
      FROM transactions
      WHERE hold_status = 'holding'
        AND hold_release_date <= NOW()
      FOR UPDATE SKIP LOCKED
    `);

    console.log(`[releaseHeldPayments] Candidates to release: ${candidates.rows.length}`);

    for (const { id } of candidates.rows) {
      // 2. Atomic state transition – double-checks hold_status to prevent double-release
      const updateRes = await client.query(
        `UPDATE transactions
         SET hold_status  = 'released',
             released_at  = NOW(),
             status       = 'completed',
             updated_at   = NOW()
         WHERE id = $1 AND hold_status = 'holding'
         RETURNING *`,
        [id]
      );

      if (updateRes.rowCount !== 1) {
        console.warn(`[releaseHeldPayments] Skipped ${id} – already released by concurrent worker`);
        continue;
      }

      const tx = updateRes.rows[0];

      // 3. Credit vendor: move amount from held → available
      await client.query(
        `UPDATE users
         SET held_balance      = GREATEST(held_balance - $1, 0),
             available_balance = available_balance + $2,
             updated_at        = NOW()
         WHERE id = $3`,
        [tx.amount, tx.net_amount, tx.payee_id]
      );

      // 4. Wallet ledger – vendor_release entry
      await client.query(
        `INSERT INTO wallet_ledger (user_id, amount, type, transaction_id, note)
         VALUES ($1, $2, 'vendor_release', $3, 'Auto-released after hold period')`,
        [tx.payee_id, tx.net_amount, tx.id]
      );

      // 5. Auto-close the linked ticket with a system comment
      const ticketRes = await client.query(
        `SELECT id, title, created_by FROM tickets WHERE linked_transaction_id = $1 LIMIT 1`,
        [tx.id]
      );
      const ticket = ticketRes.rows[0];

      if (ticket) {
        await client.query(
          `INSERT INTO ticket_comments
             (ticket_id, sender_id, sender_role, message, is_internal)
           VALUES ($1, $2, 'system', 'Payment released automatically after hold period. Ticket closed.', false)`,
          [ticket.id, tx.payee_id]
        );

        await client.query(
          `UPDATE tickets
           SET status = 'closed', resolution_notes = 'Auto-closed: payment released.', updated_at = NOW()
           WHERE id = $1`,
          [ticket.id]
        );
      }

      releasedCount++;
      console.log(
        `[releaseHeldPayments] Released tx ${tx.id} | vendor ${tx.payee_id} | net $${tx.net_amount}`
      );

      // 6. Fire notifications (outside the transaction to avoid blocking)
      setImmediate(async () => {
        try {
          await NotificationService.createPaymentReleased(tx.payee_id, parseFloat(tx.net_amount));
          if (ticket) {
            await NotificationService.createTicketAutoClosed(tx.payee_id, ticket.title);
          }
        } catch (notifErr) {
          console.error('[releaseHeldPayments] Notification error:', notifErr);
        }
      });
    }

    await client.query('COMMIT');
    console.log(`[releaseHeldPayments] Done. Released ${releasedCount} transaction(s).`);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('[releaseHeldPayments] Error – rolled back:', err);
    throw err;
  } finally {
    client.release();
  }
}

/**
 * 1-day-before reminder: runs daily at 08:00.
 * Notifies vendors whose payment releases tomorrow.
 */
export async function sendHoldReleaseReminders(): Promise<void> {
  const { query } = await import('../db');
  const rows = await query(`
    SELECT t.id, t.payee_id, t.amount, t.net_amount, t.hold_release_date
    FROM transactions
    WHERE hold_status = 'holding'
      AND hold_release_date::date = CURRENT_DATE + INTERVAL '1 day'
  `);

  for (const tx of rows.rows) {
    try {
      await NotificationService.createHoldReleaseReminder(
        tx.payee_id,
        parseFloat(tx.net_amount),
        new Date(tx.hold_release_date)
      );
    } catch (e) {
      console.error('[sendHoldReleaseReminders] Error for tx', tx.id, e);
    }
  }
  console.log(`[sendHoldReleaseReminders] Reminded ${rows.rows.length} vendor(s).`);
}
