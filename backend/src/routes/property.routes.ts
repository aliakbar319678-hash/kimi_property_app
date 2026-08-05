import { Router } from 'express';
import { PropertyService } from '../services/property.service';
import { AuditService } from '../services/audit.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { validate, schemas } from '../utils/validation';
import { query } from '../db';
import jwt from 'jsonwebtoken';
import { config } from '../config';

/**
 * Optional auth middleware — attaches user if JWT is present, but does NOT block guests.
 * Use this for public endpoints that behave differently for logged-in users.
 */
async function optionalAuth(req: AuthRequest, _res: any, next: () => void) {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    if (token) {
      const decoded = jwt.verify(token, config.jwtSecret) as any;
      const userResult = await query(
        'SELECT id, email, region_id FROM users WHERE id = $1 AND is_active = true',
        [decoded.userId]
      );
      if (userResult.rows.length > 0) {
        const rolesResult = await query('SELECT role FROM user_roles WHERE user_id = $1', [userResult.rows[0].id]);
        req.user = {
          id: userResult.rows[0].id,
          email: userResult.rows[0].email,
          roles: rolesResult.rows.map((r: any) => r.role),
          permissions: {},
          regionId: userResult.rows[0].region_id,
        };
      }
    }
  } catch (_) { /* Invalid/missing token — continue as guest */ }
  next();
}

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
          p.rejection_history,
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
    
    // Normal user logic (landlords should see their own properties)
    const isLandlord = req.user?.roles?.includes('landlord') || req.user?.roles?.includes('property_manager');
    if (isLandlord) {
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
          (SELECT COUNT(*) FROM units WHERE property_id = p.id) as total_units
        FROM properties p
        WHERE p.landlord_id = $1
        ORDER BY p.created_at DESC
      `, [req.user!.id]);
      return res.json({ success: true, data: result.rows });
    }
    
    // Normal user logic (or error if this is only supposed to be an admin route)
    res.status(403).json({ success: false, message: 'Forbidden' });
  } catch (e) { next(e); }
});

router.post('/', authenticate, requireRole('landlord', 'property_manager', 'admin'), validate(schemas.propertyCreate), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.create(req.body, req.user!.id);
    await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'created_property', 'property', property.id, { name: property.name }, req);
    res.status(201).json({ success: true, data: property });
  } catch (e) { next(e); }
});

// Guest + Authenticated: search properties with filters (no auth required)
router.get('/search', optionalAuth, validate(schemas.propertySearch), async (req: AuthRequest, res, next) => {
  try {
    const result = await PropertyService.search(req.body);
    res.json({ success: true, ...result });
  } catch (e) { next(e); }
});

// Guest + Authenticated: view a single property detail (no auth required)
router.get('/:id', optionalAuth, async (req: AuthRequest, res, next) => {
  try {
    const roles = req.user?.roles || [];
    const isLandlordOrAdmin = roles.includes('admin') || roles.includes('super_admin') || roles.includes('landlord') || roles.includes('property_manager');
    const filterVacantOnly = !isLandlordOrAdmin;
    const property = await PropertyService.getById(req.params.id, filterVacantOnly);
    res.json({ success: true, data: property });
  } catch (e) { next(e); }
});

router.post('/:id/units', authenticate, requireRole('landlord', 'property_manager'), async (req: AuthRequest, res, next) => {
  try {
    const unit = await PropertyService.createUnit(req.params.id, req.body);
    await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'created_unit', 'unit', unit.id, { propertyId: req.params.id, unitNumber: req.body.unitNumber }, req);
    res.status(201).json({ success: true, data: unit });
  } catch (e) { next(e); }
});

// Edit Property
router.put('/:id', authenticate, requireRole('landlord', 'property_manager', 'admin'), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.getById(req.params.id);
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin && property.landlord_id !== req.user!.id) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }
    const updated = await PropertyService.updateProperty(req.params.id, req.body);
    await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'updated_property', 'property', req.params.id, {}, req);
    res.json({ success: true, data: updated });
  } catch (e) { next(e); }
});

// Delete Property
router.delete('/:id', authenticate, requireRole('landlord', 'property_manager', 'admin'), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.getById(req.params.id);
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin && property.landlord_id !== req.user!.id) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }
    await PropertyService.deleteProperty(req.params.id);
    await AuditService.logAction(req.user!.id, req.user!.roles?.[0], 'deleted_property', 'property', req.params.id, {}, req);
    res.json({ success: true, message: 'Property deleted' });
  } catch (e) { next(e); }
});

// Edit Unit
router.put('/:propertyId/units/:unitId', authenticate, requireRole('landlord', 'property_manager', 'admin'), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.getById(req.params.propertyId);
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin && property.landlord_id !== req.user!.id) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }
    const updatedUnit = await PropertyService.updateUnit(req.params.propertyId, req.params.unitId, req.body);
    res.json({ success: true, data: updatedUnit });
  } catch (e) { next(e); }
});

// Delete Unit
router.delete('/:propertyId/units/:unitId', authenticate, requireRole('landlord', 'property_manager', 'admin'), async (req: AuthRequest, res, next) => {
  try {
    const property = await PropertyService.getById(req.params.propertyId);
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin && property.landlord_id !== req.user!.id) {
      return res.status(403).json({ success: false, message: 'Forbidden' });
    }
    await PropertyService.deleteUnit(req.params.propertyId, req.params.unitId);
    res.json({ success: true, data: { deleted: true } });
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
