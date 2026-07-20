import { Router } from 'express';
import { AdService } from '../services/ad.service';
import { authenticate, AuthRequest, requireRole } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Ads
 *   description: Advertisement and banner management
 */

/**
 * @swagger
 * /api/v1/ads/display:
 *   get:
 *     summary: Get active ads relevant to the user's location and role
 *     tags: [Ads]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: lat
 *         schema:
 *           type: number
 *         description: User's latitude
 *       - in: query
 *         name: lng
 *         schema:
 *           type: number
 *         description: User's longitude
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *         description: Optional role to filter ads for
 *     responses:
 *       200:
 *         description: List of targeted ads
 */
router.get('/display', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const lat = req.query.lat ? parseFloat(req.query.lat as string) : undefined;
    const lng = req.query.lng ? parseFloat(req.query.lng as string) : undefined;
    const roleParam = req.query.role as string;

    const roles = roleParam && req.user!.roles.includes(roleParam)
      ? [roleParam]
      : (req.user!.activeRole ? [req.user!.activeRole] : req.user!.roles);

    const ads = await AdService.getDisplayAds({ lat, lng, roles });
    res.json({ success: true, data: ads });
  } catch (e) {
    next(e);
  }
});

/**
 * @swagger
 * /api/v1/ads/webhook/location:
 *   post:
 *     summary: Webhook to process user location and return mixed ads (Geofencing)
 *     tags: [Ads]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [lat, lng]
 *             properties:
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *     responses:
 *       200:
 *         description: Mixed/Targeted ads based on location
 */
router.post('/webhook/location', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { lat, lng } = req.body;

    if (lat === undefined || lng === undefined) {
      return res.status(400).json({ success: false, message: 'Latitude and Longitude are required' });
    }

    const roles = req.user!.activeRole ? [req.user!.activeRole] : req.user!.roles;

    // Fetch matching ads from database (handles overlapping radiuses automatically via PostGIS ST_DWithin)
    const ads = await AdService.getDisplayAds({ lat, lng, roles });

    // Mix (shuffle) the ads so if multiple radiuses overlap, the ads are rotated/mixed
    const mixedAds = ads.sort(() => 0.5 - Math.random());

    res.json({ 
      success: true, 
      message: 'Location processed successfully', 
      matched_ads_count: mixedAds.length,
      data: mixedAds 
    });
  } catch (e) {
    next(e);
  }
});

/**
 * @swagger
 * /api/v1/ads:
 *   get:
 *     summary: Get all ads (Admin only)
 *     tags: [Ads]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: adType
 *         schema:
 *           type: string
 *         description: Optional filter by ad type (e.g., general, tender, landlord, vendor)
 *     responses:
 *       200:
 *         description: List of all ads
 */
router.get('/', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    const adType = req.query.adType as string;
    const ads = await AdService.getAll(adType);
    res.json({ success: true, data: ads });
  } catch (e) {
    next(e);
  }
});

/**
 * @swagger
 * /api/v1/ads:
 *   post:
 *     summary: Create a new ad/banner (Admin only)
 *     tags: [Ads]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, adType, bannerUrl, targetRoles]
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               adType:
 *                 type: string
 *               bannerUrl:
 *                 type: string
 *               targetRoles:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Decides which user roles this ad should be displayed to. An empty array [] means it shows to everyone (Global).
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *               radiusMeters:
 *                 type: number
 *               redirectUrl:
 *                 type: string
 *               isActive:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Ad created successfully
 */
router.post('/', authenticate, requireRole('admin', 'super_admin'), validate(schemas.adCreate), async (req: AuthRequest, res, next) => {
  try {
    const ad = await AdService.create(req.body);
    res.status(201).json({ success: true, data: ad });
  } catch (e) {
    next(e);
  }
});

/**
 * @swagger
 * /api/v1/ads/{id}:
 *   put:
 *     summary: Update an ad (Admin only)
 *     tags: [Ads]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Ad updated successfully
 */
router.put('/:id', authenticate, requireRole('admin', 'super_admin'), validate(schemas.adUpdate), async (req: AuthRequest, res, next) => {
  try {
    const ad = await AdService.update(req.params.id, req.body);
    res.json({ success: true, data: ad });
  } catch (e) {
    next(e);
  }
});

/**
 * @swagger
 * /api/v1/ads/{id}:
 *   delete:
 *     summary: Delete an ad (Admin only)
 *     tags: [Ads]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Ad deleted successfully
 */
router.delete('/:id', authenticate, requireRole('admin', 'super_admin'), async (req: AuthRequest, res, next) => {
  try {
    await AdService.delete(req.params.id);
    res.json({ success: true, message: 'Ad deleted successfully' });
  } catch (e) {
    next(e);
  }
});

export { router as adRouter };
