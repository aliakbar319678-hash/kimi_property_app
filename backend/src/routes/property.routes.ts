import { Router } from 'express';
import { PropertyService } from '../services/property.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { validate, schemas } from '../utils/validation';
import { query } from '../db';

const router = Router();

// Admin-facing list all properties
router.get('/', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    
    if (isAdmin) {
      // Admin gets all properties with owner info
      const result = await query(`
        SELECT 
          p.id,
          p.name as title,
          p.name,
          COALESCE(p.address_line1, p.city, 'Unknown Address') as location,
          p.address_line1,
          p.city,
          p.state_province,
          p.type,
          p.status,
          p.verification_status,
          p.amenities,
          p.images,
          p.description,
          p.created_at,
          p.updated_at,
          (SELECT COUNT(*) FROM units WHERE property_id = p.id) as total_units,
          json_build_object(
            'id', u.id,
            'display_name', u.display_name,
            'first_name', COALESCE(up.legal_first_name, split_part(u.display_name, ' ', 1)),
            'last_name', COALESCE(up.legal_last_name, split_part(u.display_name, ' ', 2)),
            'avatar_url', up.avatar_url
          ) as owner
        FROM properties p
        LEFT JOIN users u ON u.id = p.landlord_id
        LEFT JOIN user_profiles up ON up.user_id = p.landlord_id
        ORDER BY p.created_at DESC
      `);
      return res.json({ success: true, data: result.rows });
    }
    
    // Normal user logic (or error if this is only supposed to be an admin route)
    res.status(403).json({ success: false, message: 'Forbidden' });
  } catch (e) { next(e); }
});

router.post('/', authenticate, requireRole('landlord', 'property_manager', 'admin'), validate(schemas.propertyCreate), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.create(req.body, req.user!.id);
    res.status(201).json({ success: true, data: property });
  } catch (e) { next(e); }
});

router.get('/search', validate(schemas.propertySearch), async (req: AuthRequest, res, next) => {
  try {
    const result = await PropertyService.search(req.body);
    res.json({ success: true, ...result });
  } catch (e) { next(e); }
});

router.get('/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.getById(req.params.id);
    res.json({ success: true, data: property });
  } catch (e) { next(e); }
});

router.post('/:id/units', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const unit = await PropertyService.createUnit(req.params.id, req.body);
    res.status(201).json({ success: true, data: unit });
  } catch (e) { next(e); }
});

router.post('/:id/save', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const result = await PropertyService.saveProperty(req.user!.id, req.params.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.get('/saved/me', authenticate, requireRole('tenant'), async (req: AuthRequest, res, next) => {
  try {
    const saved = await PropertyService.getSaved(req.user!.id);
    res.json({ success: true, data: saved });
  } catch (e) { next(e); }
});

export { router as propertyRouter };
