import { Router } from 'express';
import { LMSService } from '../services/lms.service';
import { authenticate, AuthRequest } from '../middleware/auth';
import { adminOrJwtAuth } from '../middleware/adminKey';
import { validate, schemas } from '../utils/validation';
import { query } from '../db';

const router = Router();

// Admin-facing: list ALL courses (including unpublished)
router.get('/courses', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    // If admin key is used, return ALL courses (not just published)
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    let sql = `
      SELECT c.*, 
        COUNT(e.id) as real_enrolled_count,
        COALESCE(ROUND(AVG(NULLIF(e.progress_percent, 0))), 0) as real_completion_rate
      FROM courses c
      LEFT JOIN enrollments e ON c.id = e.course_id
      WHERE 1=1
    `;
    const params: any[] = [];
    
    if (!isAdmin) {
      sql += ' AND c.is_published = true';
    }
    
    if (req.query.category) { 
      sql += ` AND c.category = $${params.length + 1}`; 
      params.push(req.query.category); 
    }
    if (req.query.difficulty) { 
      sql += ` AND c.difficulty = $${params.length + 1}`; 
      params.push(req.query.difficulty); 
    }
    sql += ' GROUP BY c.id ORDER BY c.created_at DESC';
    const result = await query(sql, params);
    // Use metadata overrides if available, else fall back to real counts
    const rows = result.rows.map((row: any) => ({
      ...row,
      enrolled_count: (row.metadata && row.metadata.enrolled_count !== undefined)
        ? Number(row.metadata.enrolled_count)
        : Number(row.real_enrolled_count),
      completion_rate: (row.metadata && row.metadata.completion_rate !== undefined)
        ? Number(row.metadata.completion_rate)
        : Number(row.real_completion_rate)
    }));
    res.json({ success: true, data: rows });
  } catch (e) { next(e); }
});

router.get('/stats/summary', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const stats = await LMSService.getLmsSummaryStats();
    res.json({ success: true, data: stats });
  } catch (e) { next(e); }
});

router.get('/analytics', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const analytics = await LMSService.getLmsAnalytics();
    res.json({ success: true, data: analytics });
  } catch (e) { next(e); }
});

router.get('/students', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const students = await LMSService.getAllStudents();
    res.json({ success: true, data: students });
  } catch (e) { next(e); }
});

router.get('/courses/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const course = await LMSService.getCourseById(req.params.id);
    res.json({ success: true, data: course });
  } catch (e) { next(e); }
});

router.post('/courses', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const course = await LMSService.createCourse(req.body);
    res.status(201).json({ success: true, data: course });
  } catch (e) { next(e); }
});

router.put('/courses/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const course = await LMSService.updateCourse(req.params.id, req.body);
    res.json({ success: true, data: course });
  } catch (e) { next(e); }
});

router.delete('/courses/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    await LMSService.deleteCourse(req.params.id);
    res.json({ success: true, message: 'Course deleted successfully' });
  } catch (e) { next(e); }
});

router.post('/courses/:id/enroll', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const enrollment = await LMSService.enroll(req.user!.id, req.params.id);
    res.status(201).json({ success: true, data: enrollment });
  } catch (e) { next(e); }
});

router.put('/enrollments/:id/progress', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const enrollment = await LMSService.updateProgress(req.params.id, req.user!.id, req.body.progressPercent);
    res.json({ success: true, data: enrollment });
  } catch (e) { next(e); }
});

router.get('/modules/:id/quiz', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const quiz = await LMSService.getQuiz(req.params.id);
    res.json({ success: true, data: quiz });
  } catch (e) { next(e); }
});

router.post('/enrollments/:id/quiz', authenticate, validate(schemas.quizSubmit), async (req: AuthRequest, res, next) => {
  try {
    const result = await LMSService.submitQuiz(req.params.id, req.body.moduleId, req.user!.id, req.body.answers);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

router.get('/certificates', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    // Admin: return all certificates
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (isAdmin) {
      const result = await query(
        `SELECT c.*, co.title as course_title, co.category, u.display_name as user_name
         FROM certificates c
         JOIN courses co ON co.id = c.course_id
         JOIN users u ON u.id = c.user_id
         ORDER BY c.issued_date DESC`
      );
      return res.json({ success: true, data: result.rows });
    }
    const certs = await LMSService.getCertificates(req.user!.id);
    res.json({ success: true, data: certs });
  } catch (e) { next(e); }
});

router.post('/enrollments/:id/certificate', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const cert = await LMSService.issueCertificate(req.params.id, req.user!.id);
    res.status(201).json({ success: true, data: cert });
  } catch (e) { next(e); }
});

router.post('/certificates', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin) {
      return res.status(403).json({ success: false, message: 'Forbidden: Admin access required' });
    }
    const { user_id, course_id } = req.body;
    if (!user_id || !course_id) {
      return res.status(400).json({ success: false, message: 'user_id and course_id are required' });
    }
    const cert = await LMSService.issueCertificateAdmin(user_id, course_id);
    res.status(201).json({ success: true, data: cert });
  } catch (e) { next(e); }
});

// Delete a certificate by ID (admin only)
router.delete('/certificates/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  console.log('DELETE /certificates/:id called with id', req.params.id);
  try {
    const cert = await LMSService.deleteCertificate(req.params.id);
    res.json({ success: true, data: cert });
  } catch (e) {
    console.error('Error deleting certificate:', e);
    next(e);
  }
});

// Update a certificate (admin only)
router.put('/certificates/:id', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const isAdmin = req.user?.roles?.includes('admin') || req.user?.roles?.includes('super_admin');
    if (!isAdmin) {
      return res.status(403).json({ success: false, message: 'Forbidden: Admin access required' });
    }
    const cert = await LMSService.updateCertificate(req.params.id, req.body);
    res.json({ success: true, data: cert });
  } catch (e) { next(e); }
});

router.get('/certificates/:number/verify', async (req, res, next) => {
  try {
    const cert = await LMSService.verifyCertificate(req.params.number);
    res.json({ success: true, data: { valid: cert.status === 'active', ...cert } });
  } catch (e) { next(e); }
});

router.get('/dashboard', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const dashboard = await LMSService.getDashboard(req.user!.id);
    res.json({ success: true, data: dashboard });
  } catch (e) { next(e); }
});

router.get('/resources', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const result = await query('SELECT * FROM lms_resources ORDER BY created_at DESC');
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

router.post('/resources', adminOrJwtAuth, async (req: AuthRequest, res, next) => {
  try {
    const { title, type, description, file_url, file_size } = req.body;
    const result = await query(
      'INSERT INTO lms_resources (title, type, description, file_url, file_size) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [title, type, description, file_url, file_size]
    );
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (e) { next(e); }
});

export { router as lmsRouter };
