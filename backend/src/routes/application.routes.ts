import { Router } from 'express';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { pool } from '../db';
import { v4 as uuidv4 } from 'uuid';

const router = Router();

/**
 * @swagger
 * /api/v1/applications:
 *   post:
 *     summary: Submit a tenant application
 *     tags: [Applications]
 *     security:
 *       - bearerAuth: []
 */
router.post('/', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  const client = await pool.connect();
  try {
    const { propertyId, unitId } = req.body;
    
    // Fetch landlord_id from property
    const propRes = await client.query('SELECT landlord_id FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) {
       res.status(404).json({ success: false, message: 'Property not found' });
       return;
    }
    const landlordId = propRes.rows[0].landlord_id;

    // Insert application
    const appRes = await client.query(
      `INSERT INTO applications (
        property_id, unit_id, tenant_id, landlord_id, screening_fee_paid, screening_status, approval_status
      ) VALUES ($1, $2, $3, $4, true, 'pending', 'pending') RETURNING *`,
      [propertyId, unitId, req.user!.id, landlordId]
    );

    res.status(201).json({ success: true, data: appRes.rows[0] });
  } catch (e) {
    next(e);
  } finally {
    client.release();
  }
});

/**
 * @swagger
 * /api/v1/applications/landlord:
 *   get:
 *     summary: Get landlord applications
 *     tags: [Applications]
 *     security:
 *       - bearerAuth: []
 */
router.get('/landlord', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const appsRes = await pool.query(
      `SELECT a.*, u.display_name as tenant_name, u.email as tenant_email, p.name as property_name, un.unit_number
       FROM applications a
       JOIN users u ON a.tenant_id = u.id
       JOIN properties p ON a.property_id = p.id
       JOIN units un ON a.unit_id = un.id
       WHERE a.landlord_id = $1
       ORDER BY a.created_at DESC`,
      [req.user!.id]
    );
    res.json({ success: true, data: appsRes.rows });
  } catch (e) {
    next(e);
  }
});

/**
 * @swagger
 * /api/v1/applications/{id}/decision:
 *   patch:
 *     summary: Approve, reject or conditionally approve application
 *     tags: [Applications]
 *     security:
 *       - bearerAuth: []
 */
router.patch('/:id/decision', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const { approval_status, rejection_reason, conditional_terms } = req.body;
    
    // Verify ownership
    const appRes = await client.query('SELECT * FROM applications WHERE id = $1 AND landlord_id = $2', [req.params.id, req.user!.id]);
    if (appRes.rows.length === 0) {
      await client.query('ROLLBACK');
      res.status(404).json({ success: false, message: 'Application not found' });
      return;
    }
    const application = appRes.rows[0];

    // Update application
    const updatedRes = await client.query(
      `UPDATE applications SET 
        approval_status = $1, 
        rejection_reason = $2, 
        conditional_terms = $3,
        updated_at = NOW()
       WHERE id = $4 RETURNING *`,
      [approval_status, rejection_reason || null, conditional_terms || '{}', req.params.id]
    );

    // If approved, create lease automatically
    if (approval_status === 'approved') {
      const unitRes = await client.query('SELECT rent_amount, deposit_amount FROM units WHERE id = $1', [application.unit_id]);
      const rentAmount = unitRes.rows[0]?.rent_amount || 0;
      const depositAmount = unitRes.rows[0]?.deposit_amount || 0;
      
      const startDate = new Date();
      const endDate = new Date();
      endDate.setFullYear(endDate.getFullYear() + 1); // Default 1 year lease

      await client.query(
        `INSERT INTO leases (
          tenant_id, unit_id, property_id, landlord_id, start_date, end_date, rent_amount, deposit_amount, status
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'active')`,
        [application.tenant_id, application.unit_id, application.property_id, application.landlord_id, startDate, endDate, rentAmount, depositAmount]
      );
      
      // Update unit status to occupied
      await client.query('UPDATE units SET status = $1 WHERE id = $2', ['occupied', application.unit_id]);
    }

    await client.query('COMMIT');
    res.json({ success: true, data: updatedRes.rows[0] });
  } catch (e) {
    await client.query('ROLLBACK');
    next(e);
  } finally {
    client.release();
  }
});

/**
 * @swagger
 * /api/v1/applications/tenant:
 *   get:
 *     summary: Get tenant applications
 *     tags: [Applications]
 *     security:
 *       - bearerAuth: []
 */
router.get('/tenant', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const appsRes = await pool.query(
      `SELECT a.*, p.name as property_name, un.unit_number
       FROM applications a
       JOIN properties p ON a.property_id = p.id
       JOIN units un ON a.unit_id = un.id
       WHERE a.tenant_id = $1
       ORDER BY a.created_at DESC`,
      [req.user!.id]
    );
    res.json({ success: true, data: appsRes.rows });
  } catch (e) {
    next(e);
  }
});

export { router as applicationRouter };
