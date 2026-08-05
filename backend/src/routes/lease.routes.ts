import { Router } from 'express';
import { LeaseService } from '../services/lease.service';
import { StripeService } from '../services/stripe.service';
import { AuditService } from '../services/audit.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

// Create a new lease
router.post(
  '/',
  authenticate,
  requireRole('landlord', 'property_manager'),
  validate(schemas.leaseCreate),
  async (req: AuthRequest, res, next) => {
    try {
      const lease = await LeaseService.create(req.body, req.user!.id);
      await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'drafted_lease', 'lease', lease.id, {}, req);
      res.status(201).json({ success: true, data: lease });
    } catch (e) {
      next(e);
    }
  },
);

// Get lease by ID
router.get(
  '/:id',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const lease = await LeaseService.getById(req.params.id);
      res.json({ success: true, data: lease });
    } catch (e) {
      next(e);
    }
  }
);

// Update lease status
router.patch(
  '/:id/status',
  authenticate,
  requireRole('landlord', 'property_manager'),
  async (req: AuthRequest, res, next) => {
    try {
      const { status } = req.body;
      const validStatuses = ['active', 'terminated', 'expired', 'draft', 'renewed'];
      if (!status || !validStatuses.includes(status)) {
        return res.status(400).json({ success: false, error: 'Invalid status' });
      }
      const lease = await LeaseService.updateStatus(req.params.id, status);
      await AuditService.logAction(req.user!.id, req.user!.roles?.[0], `lease_status_changed_to_${status}`, 'lease', lease.id, { status }, req);
      res.json({ success: true, data: lease });
    } catch (e) {
      next(e);
    }
  }
);

// Dashboard view for logged‑in user
router.get(
  '/dashboard',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const leases = await LeaseService.getDashboard(
        req.user!.id,
        req.user!.activeRole!,
      );
      res.json({ success: true, data: leases });
    } catch (e) {
      next(e);
    }
  },
);

// Leases that are expiring soon
router.get(
  '/expiring-soon',
  authenticate,
  requireRole('landlord', 'property_manager'),
  async (req: AuthRequest, res, next) => {
    try {
      const leases = await LeaseService.getExpiringSoon(req.user!.id);
      res.json({ success: true, data: leases });
    } catch (e) {
      next(e);
    }
  },
);

// Tenant initiates payment for a lease
router.post(
  '/:id/pay',
  authenticate,
  requireRole('tenant'),
  validate(schemas.paymentInitiate),
  async (req: AuthRequest, res, next) => {
    try {
      const leaseId = req.params.id;
      const { amount, paymentMethod } = req.body;
      const tenantId = req.user!.id;
      const result = await StripeService.initiatePayment(
        leaseId,
        tenantId,
        amount,
        paymentMethod,
      );
      await AuditService.logAction(tenantId, 'tenant', 'paid_rent', 'lease', leaseId, { amount, paymentMethod }, req);
      res.json({ success: true, data: result });
    } catch (e) {
      next(e);
    }
  },
);

// Renew a lease (e.g., after expiry or extension)
router.post(
  '/:id/renew',
  authenticate,
  requireRole('landlord', 'property_manager'),
  async (req: AuthRequest, res, next) => {
    try {
      const lease = await LeaseService.renewLease(
        req.params.id,
        req.user!.id,
        req.body,
      );
      await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'renewed_lease', 'lease', lease.id, {}, req);
      res.json({ success: true, data: lease });
    } catch (e) {
      next(e);
    }
  },
);

// Fetch inspections for a lease (PDF generation expects a specific shape)
router.get(
  '/:id/inspections',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const inspections = await LeaseService.getInspections(req.params.id);
      // PDF expects exactly { lease_id, inspections: [...] }
      res.json({ lease_id: req.params.id, inspections });
    } catch (e) {
      next(e);
    }
  },
);

// Submit a new inspection report for a lease
router.post(
  '/:id/inspections',
  authenticate,
  async (req: AuthRequest, res, next) => {
    try {
      const inspection = await LeaseService.submitInspection(
        req.params.id,
        req.body,
        req.user!.id,
      );
      res.status(201).json({ success: true, data: inspection });
    } catch (e) {
      next(e);
    }
  },
);

export { router as leaseRouter };
