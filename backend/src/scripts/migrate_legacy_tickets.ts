/**
 * migrate_legacy_tickets.ts
 * ─────────────────────────
 * One-time migration script: maps legacy `support_tickets` string fields to
 * proper UUID foreign keys in the new `tickets` table.
 *
 * Run: ts-node src/scripts/migrate_legacy_tickets.ts
 */

import fs from 'fs';
import path from 'path';
import { pool } from '../db';

// Simple Levenshtein distance for fuzzy name matching
function levenshtein(a: string, b: string): number {
  const m = a.length, n = b.length;
  const dp: number[][] = Array.from({ length: m + 1 }, (_, i) =>
    Array.from({ length: n + 1 }, (_, j) => (i === 0 ? j : j === 0 ? i : 0))
  );
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] = a[i - 1] === b[j - 1]
        ? dp[i - 1][j - 1]
        : 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
    }
  }
  return dp[m][n];
}

async function resolveUser(
  client: any,
  nameOrEmail: string | null,
  allUsers: { id: string; email: string; display_name: string }[]
): Promise<string | null> {
  if (!nameOrEmail) return null;
  const val = nameOrEmail.trim().toLowerCase();

  // 1. Exact email match
  const byEmail = allUsers.find((u) => u.email.toLowerCase() === val);
  if (byEmail) return byEmail.id;

  // 2. Exact display_name match
  const byName = allUsers.find((u) => u.display_name?.toLowerCase() === val);
  if (byName) return byName.id;

  // 3. Fuzzy name match (Levenshtein ≤ 2)
  let best: { id: string; dist: number } | null = null;
  for (const u of allUsers) {
    const dist = levenshtein(val, (u.display_name ?? '').toLowerCase());
    if (dist <= 2 && (!best || dist < best.dist)) {
      best = { id: u.id, dist };
    }
  }
  return best?.id ?? null;
}

async function migrate() {
  const client = await pool.connect();
  const errors: any[] = [];

  try {
    console.log('📦 Fetching all users for mapping…');
    const usersRes = await client.query(
      'SELECT id, email, display_name FROM users'
    );
    const allUsers = usersRes.rows;

    console.log('📦 Fetching legacy support_tickets…');
    const legacyRes = await client.query(
      'SELECT * FROM support_tickets ORDER BY id ASC'
    );
    const legacyTickets = legacyRes.rows;
    console.log(`  Found ${legacyTickets.length} legacy tickets.`);

    await client.query('BEGIN');

    let migratedCount = 0;
    for (const lt of legacyTickets) {
      let notes = '';
      const createdById = await resolveUser(client, lt.reporter, allUsers);
      if (!createdById && lt.reporter) {
        notes += `[Migration] Original reporter: "${lt.reporter}". `;
        errors.push({ legacy_id: lt.id, field: 'reporter', value: lt.reporter });
      }

      // Map category
      const categoryMap: Record<string, string> = {
        payment: 'billing',
        maintenance: 'maintenance',
        access: 'access',
      };
      const category = categoryMap[lt.reporter_role?.toLowerCase()] ?? 'general';

      const description =
        (lt.description ?? '') + (notes ? `\n\n${notes.trim()}` : '');

      await client.query(
        `INSERT INTO tickets
           (title, description, category, priority, status,
            created_by, resolution_notes, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
        [
          lt.title,
          description,
          category,
          (lt.priority ?? 'medium').toLowerCase(),
          (lt.status ?? 'open').toLowerCase(),
          createdById,
          lt.resolution_notes ?? null,
          lt.created_at,
          lt.updated_at,
        ]
      );
      migratedCount++;
    }

    // Rename old table as backup
    await client.query(
      'ALTER TABLE support_tickets RENAME TO support_tickets_legacy_backup'
    );
    // Rename updates table too
    await client.query(
      'ALTER TABLE support_ticket_updates RENAME TO support_ticket_updates_legacy_backup'
    );

    await client.query('COMMIT');
    console.log(`✅ Migration complete: ${migratedCount} tickets migrated.`);

    if (errors.length > 0) {
      const outPath = path.join(process.cwd(), 'legacy_ticket_migration_errors.json');
      fs.writeFileSync(outPath, JSON.stringify(errors, null, 2));
      console.warn(`⚠️  ${errors.length} unmatched reporters logged to ${outPath}`);
    }
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Migration failed – rolled back:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

migrate().catch(console.error);
