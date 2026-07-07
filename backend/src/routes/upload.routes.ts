import { Router } from 'express';
import multer from 'multer';
import { UploadService } from '../services/upload.service';
import { authenticate, AuthRequest } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// Setup local storage for generic uploads
import fs from 'fs';
import path from 'path';

const uploadDir = path.join(__dirname, '../../public/uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const localStorage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    let ext = path.extname(file.originalname);
    if (!ext && file.mimetype) {
      ext = '.' + file.mimetype.split('/')[1];
      if (ext === '.svg+xml') ext = '.svg';
      if (ext === '.jpeg') ext = '.jpg';
    }
    const safeName = file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '');
    cb(null, uniqueSuffix + '-' + safeName + (safeName.endsWith(ext) ? '' : ext));
  }
});
const imageFilter = (req: any, file: any, cb: any) => {
  // Accept any mimetype for generic uploads (documents, images, audio, video)
  cb(null, true);
};

const localUpload = multer({ 
  storage: localStorage, 
  limits: { fileSize: 500 * 1024 * 1024 }, // 500MB limit - supports image and video uploads
  fileFilter: imageFilter
});

// Existing memory storage for S3 uploads
const memoryUpload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 20 * 1024 * 1024 } });

// --- Generic Local Upload Route (accepts admin key OR JWT) ---
router.post('/generic', adminOrJwtAuth, localUpload.single('file'), (req: AuthRequest, res) => {
  if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded or invalid file type' });
  // Generate public URL - use the full absolute URL so Laravel can display it
  const host = req.get('host') || 'localhost:5000';
  const protocol = req.headers['x-forwarded-proto'] || req.protocol || 'http';
  const url = `${protocol}://${host}/uploads/${req.file.filename}`;
  res.json({ success: true, data: { url, filename: req.file.filename } });
});

router.post('/property/:id/image', authenticate, memoryUpload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadPropertyImage(req.params.id, req.file.buffer, req.file.originalname, req.file.mimetype, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/work-order/:id/photo', authenticate, memoryUpload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadWorkOrderPhoto(req.params.id, req.file.buffer, req.file.originalname, req.file.mimetype, req.user!.id);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.post('/kyc/:docType', authenticate, memoryUpload.single('file'), async (req: AuthRequest, res, next) => {
  try {
    if (!req.file) throw new AppError('No file uploaded', 400);
    const result = await UploadService.uploadKycDocument(req.user!.id, req.params.docType, req.file.buffer, req.file.originalname, req.file.mimetype);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

export { router as uploadRouter };
