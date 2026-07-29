import { Router } from 'express';
import { query } from '../db';
import { authenticate, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';

const router = Router();

// Get all escrow ledgers (Admin only)
router.get('/', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const escrows = await query(`
      SELECT e.*, u.display_name as user_name, p.name as property_name
      FROM escrow_ledgers e
      JOIN users u ON e.user_id = u.id
      LEFT JOIN properties p ON e.property_id = p.id
      ORDER BY e.created_at DESC
    `);
    res.json({ success: true, data: escrows.rows });
  } catch (e) { next(e); }
});

// Hold a new deposit
router.post('/hold', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const { user_id, user_role, property_id, lease_id, amount, deposit_type } = req.body;
    const escrowRes = await query(
      `INSERT INTO escrow_ledgers (user_id, user_role, property_id, lease_id, amount, deposit_type, status)
       VALUES ($1, $2, $3, $4, $5, $6, 'held') RETURNING *`,
      [user_id, user_role || 'tenant', property_id, lease_id, amount, deposit_type || 'security']
    );
    res.status(201).json({ success: true, data: escrowRes.rows[0] });
  } catch (e) { next(e); }
});

// Release a deposit
router.post('/:id/release', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const { deductions } = req.body;
    const escrowId = req.params.id;

    // In a real implementation, if deductions > 0, we'd transfer funds from escrow to operations
    const status = (deductions && deductions > 0) ? 'partially_deducted' : 'released';

    const escrowRes = await query(
      `UPDATE escrow_ledgers SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *`,
      [status, escrowId]
    );
    
    res.json({ success: true, data: escrowRes.rows[0], message: 'Deposit released successfully' });
  } catch (e) { next(e); }
});

// Export escrow ledgers
router.get('/export', adminOrJwtAuth, async (req: any, res, next) => {
  try {
    const escrows = await query(`
      SELECT e.*, u.display_name as user_name, p.name as property_name
      FROM escrow_ledgers e
      JOIN users u ON e.user_id = u.id
      LEFT JOIN properties p ON e.property_id = p.id
      ORDER BY e.created_at DESC
    `);
    
    let csv = 'Escrow ID,User Name,Role,Property Name,Amount,Status,Type,Date\n';
    escrows.rows.forEach((e: any) => {
      csv += `${e.id},${e.user_name},${e.user_role},${e.property_name || 'N/A'},${e.amount},${e.status},${e.deposit_type},${e.created_at}\n`;
    });

    res.header('Content-Type', 'text/csv');
    res.attachment('escrow_ledger.csv');
    res.send(csv);
  } catch (e) { next(e); }
});

export { router as escrowRouter };
