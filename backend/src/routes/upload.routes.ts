import { Router } from 'express';
import multer from 'multer';
import { UploadService } from '../services/upload.service';
import { authenticate, AuthRequest } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });

/**
 * @swagger
 * tags:
 *   name: Uploads
 *   description: File upload endpoints
 */

/**
 * @swagger
 * /api/v1/uploads/property/{id}/image:
 *   post:
 *     summary: Upload property image
 *     tags: [Uploads]
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
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Image uploaded
 */
router.post('/property/:id/image', authenticate, upload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadPropertyImage(req.params.id, req.file.buffer, req.file.originalname, req.file.mimetype, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/uploads/work-order/{id}/photo:
 *   post:
 *     summary: Upload work order photo
 *     tags: [Uploads]
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
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Photo uploaded
 */
router.post('/work-order/:id/photo', authenticate, upload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadWorkOrderPhoto(req.params.id, req.file.buffer, req.file.originalname, req.file.mimetype, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/uploads/kyc/{docType}:
 *   post:
 *     summary: Upload KYC document
 *     tags: [Uploads]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: docType
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Document uploaded
 */
router.post('/kyc/:docType', authenticate, upload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadKycDocument(req.user!.id, req.params.docType, req.file.buffer, req.file.originalname, req.file.mimetype);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/uploads/avatar:
 *   post:
 *     summary: Upload profile picture (avatar)
 *     description: |
 *       Uploads a new profile picture for the authenticated user.
 *       The `avatar_url` field on the user record is updated immediately.
 *
 *       **Supported formats:** JPEG · PNG · WebP · GIF · AVIF · SVG · BMP · TIFF
 *
 *       **Max file size:** 10 MB
 *     tags: [Uploads]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - file
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *                 description: |
 *                   Image file to upload.
 *                   Accepted: image/jpeg, image/png, image/webp, image/gif,
 *                   image/avif, image/svg+xml, image/bmp, image/tiff
 *     responses:
 *       200:
 *         description: Avatar uploaded successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     key:
 *                       type: string
 *                       example: avatars/user-uuid/550e8400-e29b-41d4-a716-446655440000.png
 *                     url:
 *                       type: string
 *                       format: uri
 *                       example: https://s3.amazonaws.com/propadmin-uploads/avatars/user-uuid/photo.png?X-Amz-Signature=...
 *                     expiresIn:
 *                       type: integer
 *                       description: Signed URL validity in seconds (1 year)
 *                       example: 31536000
 *       400:
 *         description: No file provided or unsupported file type
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *             example:
 *               success: false
 *               message: 'Unsupported file type "application/pdf". Allowed types: JPEG, PNG, WebP, GIF, AVIF, SVG, BMP, TIFF'
 *       401:
 *         $ref: '#/components/responses/Unauthorized'
 */
router.post('/avatar', authenticate, upload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadAvatar(
      req.user!.id,
      req.file.buffer,
      req.file.originalname,
      req.file.mimetype
    );
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/uploads/inspection/{id}/photo:
 *   post:
 *     summary: Upload inspection photo
 *     tags: [Uploads]
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
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Inspection photo uploaded
 */
router.post('/inspection/:id/photo', authenticate, upload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadInspectionPhoto(req.params.id, req.file.buffer, req.file.originalname, req.file.mimetype, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as uploadRouter };
