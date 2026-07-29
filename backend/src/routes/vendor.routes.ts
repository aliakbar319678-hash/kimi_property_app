import { Router } from 'express';
import { VendorService } from '../services/vendor.service';
import { MaintenanceService } from '../services/maintenance.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';

const router = Router();

router.get('/my-bids', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const bids = await VendorService.getMyBids(req.user!.id, req.query.status as string);
    res.json({ success: true, data: bids });
  } catch (e) { next(e); }
});

router.get('/stats', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const stats = await VendorService.getVendorStats(req.user!.id);
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

router.get('/jobs', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const jobs = await MaintenanceService.getVendorJobs(req.user!.id, req.query.status as string);
    res.json({ success: true, data: jobs });
  } catch (e) { next(e); }
});

// ─── Invoicing ─────────────────────────────────────────────────────────────

router.get('/invoices', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const invoices = await VendorService.getInvoices(req.user!.id);
    res.json({ success: true, data: invoices });
  } catch (e) { next(e); }
});

router.post('/invoices', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const { workOrderId, jobId, clientId, clientName, items, taxAmount, notes, dueDate, currency } = req.body;
    if (!clientId || !clientName || !items || !items.length) {
      return res.status(400).json({ success: false, message: 'clientId, clientName, and items are required' });
    }
    const invoice = await VendorService.createInvoice(req.user!.id, {
      workOrderId: workOrderId || jobId || undefined,
      clientId, clientName, items, taxAmount, notes, dueDate, currency
    });
    res.status(201).json({ success: true, data: invoice });
  } catch (e) { next(e); }
});

router.get('/invoices/:id/pdf', authenticate, requireRole('vendor'), async (req: AuthRequest, res, next) => {
  try {
    const pdfBuffer = await VendorService.generateInvoicePDF(req.params.id, req.user!.id);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="invoice_${req.params.id}.pdf"`);
    res.send(pdfBuffer);
  } catch (e) { next(e); }
});

router.get('/:id/insurance', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const insurance = await VendorService.getVendorInsurance(req.params.id);
    res.json(insurance); // Returns {vendor_id: "...", policy_number: "..."} exactly like PDF
  } catch (e) { next(e); }
});

export { router as vendorRouter };
