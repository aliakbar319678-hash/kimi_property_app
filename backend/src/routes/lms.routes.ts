import { Router } from 'express';
import { LMSService } from '../services/lms.service';
import { authenticate, AuthRequest } from '../middleware/auth';
import { validate, schemas } from '../utils/validation';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: LMS
 *   description: Learning Management System (Courses & Certificates)
 */

/**
 * @swagger
 * /api/v1/lms/courses:
 *   post:
 *     summary: Create a new course
 *     tags: [LMS]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, description, category]
 *             properties:
 *               title: { type: string }
 *               description: { type: string }
 *               category: { type: string }
 *               difficulty: { type: string }
 *               is_published: { type: boolean }
 *     responses:
 *       201:
 *         description: Course created
 */
router.post('/courses', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const courseData = { ...req.body, instructor_id: req.user!.id };
    const course = await LMSService.createCourse(courseData);
    res.status(201).json({ success: true, data: course });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/courses:
 *   get:
 *     summary: Get all courses
 *     tags: [LMS]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of courses
 */
router.get('/courses', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const courses = await LMSService.getCourses(req.query);
    res.json({ success: true, data: courses });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/courses/{id}:
 *   get:
 *     summary: Get course by ID
 *     tags: [LMS]
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
 *         description: Course details
 */
router.get('/courses/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const course = await LMSService.getCourseById(req.params.id);
    res.json({ success: true, data: course });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/courses/{id}/enroll:
 *   post:
 *     summary: Enroll in a course
 *     tags: [LMS]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       201:
 *         description: Enrolled successfully
 */
router.post('/courses/:id/enroll', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const enrollment = await LMSService.enroll(req.user!.id, req.params.id);
    res.status(201).json({ success: true, data: enrollment });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/enrollments/{id}/progress:
 *   put:
 *     summary: Update course progress
 *     tags: [LMS]
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
 *             properties:
 *               progressPercent:
 *                 type: number
 *     responses:
 *       200:
 *         description: Progress updated
 */
router.put('/enrollments/:id/progress', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const enrollment = await LMSService.updateProgress(req.params.id, req.user!.id, req.body.progressPercent);
    res.json({ success: true, data: enrollment });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/modules/{id}/quiz:
 *   get:
 *     summary: Get module quiz
 *     tags: [LMS]
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
 *         description: Quiz details
 */
router.get('/modules/:id/quiz', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const quiz = await LMSService.getQuiz(req.params.id);
    res.json({ success: true, data: quiz });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/enrollments/{id}/quiz:
 *   post:
 *     summary: Submit quiz answers
 *     tags: [LMS]
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
 *             properties:
 *               moduleId:
 *                 type: string
 *               answers:
 *                 type: array
 *                 items:
 *                   type: object
 *     responses:
 *       200:
 *         description: Quiz graded
 */
router.post('/enrollments/:id/quiz', authenticate, validate(schemas.quizSubmit), async (req: AuthRequest, res, next) => {
  try {
    const result = await LMSService.submitQuiz(req.params.id, req.body.moduleId, req.user!.id, req.body.answers);
    res.json({ success: true, data: result });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/certificates:
 *   get:
 *     summary: Get user certificates
 *     tags: [LMS]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of certificates
 */
router.get('/certificates', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const certs = await LMSService.getCertificates(req.user!.id);
    res.json({ success: true, data: certs });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/enrollments/{id}/certificate:
 *   post:
 *     summary: Issue certificate for completed course
 *     tags: [LMS]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       201:
 *         description: Certificate issued
 */
router.post('/enrollments/:id/certificate', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const cert = await LMSService.issueCertificate(req.params.id, req.user!.id);
    res.status(201).json({ success: true, data: cert });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/certificates/{number}/verify:
 *   get:
 *     summary: Verify a certificate
 *     tags: [LMS]
 *     parameters:
 *       - in: path
 *         name: number
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Certificate verification status
 */
router.get('/certificates/:number/verify', async (req, res, next) => {
  try {
    const cert = await LMSService.verifyCertificate(req.params.number);
    res.json({ success: true, data: { valid: cert.status === 'active', ...cert } });
  } catch (e) { next(e); }
});

/**
 * @swagger
 * /api/v1/lms/dashboard:
 *   get:
 *     summary: Get LMS dashboard
 *     tags: [LMS]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard stats
 */
router.get('/dashboard', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const dashboard = await LMSService.getDashboard(req.user!.id);
    res.json({ success: true, data: dashboard });
  } catch (e) { next(e); }
});

export { router as lmsRouter };
