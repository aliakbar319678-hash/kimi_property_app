import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';
import { v4 as uuidv4 } from 'uuid';

export class LMSService {
  static async createCourse(data: any) {
    const res = await query(
      `INSERT INTO courses (title, description, category, difficulty, is_published)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [data.title, data.description, data.category, data.difficulty || 'beginner', data.is_published || false]
    );
    return res.rows[0];
  }

  static async getCourses(filters: any) {
    let sql = 'SELECT * FROM courses WHERE is_published = true';
    const params: any[] = [];
    if (filters.category) { sql += ` AND category = $${params.length + 1}`; params.push(filters.category); }
    if (filters.difficulty) { sql += ` AND difficulty = $${params.length + 1}`; params.push(filters.difficulty); }
    sql += ' ORDER BY created_at DESC';
    const res = await query(sql, params);
    return res.rows;
  }

  static async getCourseById(id: string) {
    const courseRes = await query('SELECT * FROM courses WHERE id = $1', [id]);
    if (courseRes.rows.length === 0) throw new AppError('Course not found', 404);
    const modulesRes = await query('SELECT * FROM modules WHERE course_id = $1 ORDER BY sort_order', [id]);
    return { ...courseRes.rows[0], modules: modulesRes.rows };
  }

  static async enroll(userId: string, courseId: string) {
    const existing = await query('SELECT * FROM enrollments WHERE user_id = $1 AND course_id = $2', [userId, courseId]);
    if (existing.rows.length > 0) return existing.rows[0];
    const res = await query(
      'INSERT INTO enrollments (user_id, course_id) VALUES ($1, $2) RETURNING *',
      [userId, courseId]
    );
    return res.rows[0];
  }

  static async updateProgress(enrollmentId: string, userId: string, progressPercent: number) {
    const res = await query(
      `UPDATE enrollments SET progress_percent = $1, status = CASE WHEN $1 >= 100 THEN 'completed' ELSE status END, completed_at = CASE WHEN $1 >= 100 THEN NOW() ELSE completed_at END WHERE id = $2 AND user_id = $3 RETURNING *`,
      [progressPercent, enrollmentId, userId]
    );
    if (res.rows.length === 0) throw new AppError('Enrollment not found', 404);
    return res.rows[0];
  }

  static async getQuiz(moduleId: string) {
    const res = await query('SELECT * FROM quizzes WHERE module_id = $1', [moduleId]);
    if (res.rows.length === 0) throw new AppError('Quiz not found', 404);
    return res.rows[0];
  }

  static async submitQuiz(enrollmentId: string, moduleId: string, userId: string, answers: any[]) {
    return withTransaction(async (client) => {
      const quizRes = await client.query('SELECT questions FROM quizzes WHERE module_id = $1', [moduleId]);
      if (quizRes.rows.length === 0) throw new AppError('Quiz not found', 404);
      const questions = quizRes.rows[0].questions;

      let correct = 0;
      for (const ans of answers) {
        const q = questions.find((q: any) => q.id === ans.questionId);
        if (q && q.options.find((o: any) => o.id === ans.selectedOptionId)?.is_correct) correct++;
      }
      const scorePercent = Math.round((correct / questions.length) * 100);
      const passed = scorePercent >= 70; // default passing score

      const attemptRes = await client.query(
        'INSERT INTO quiz_attempts (enrollment_id, module_id, score_percent, answers, passed) VALUES ($1, $2, $3, $4, $5) RETURNING *',
        [enrollmentId, moduleId, scorePercent, JSON.stringify(answers), passed]
      );
      return attemptRes.rows[0];
    });
  }

  static async getCertificates(userId: string) {
    const res = await query(
      `SELECT c.*, co.title as course_title, co.category
       FROM certificates c
       JOIN courses co ON co.id = c.course_id
       WHERE c.user_id = $1 ORDER BY c.issued_date DESC`,
      [userId]
    );
    return res.rows;
  }

  static async issueCertificate(enrollmentId: string, userId: string) {
    return withTransaction(async (client) => {
      const enrollRes = await client.query('SELECT * FROM enrollments WHERE id = $1 AND user_id = $2 AND status = $3', [enrollmentId, userId, 'completed']);
      if (enrollRes.rows.length === 0) throw new AppError('Enrollment not completed', 400);
      const enrollment = enrollRes.rows[0];

      const courseRes = await client.query('SELECT title, certificate_template FROM courses WHERE id = $1', [enrollment.course_id]);
      const course = courseRes.rows[0];

      const userRes = await client.query('SELECT display_name FROM users WHERE id = $1', [userId]);
      const displayName = userRes.rows[0]?.display_name || 'Student';

      const certNumber = `CERT-${uuidv4().split('-')[0].toUpperCase()}-${new Date().getFullYear()}`;
      const hash = require('crypto').createHash('sha256').update(`${userId}:${enrollment.course_id}:${new Date().toISOString()}`).digest('hex');

      const certRes = await client.query(
        `INSERT INTO certificates (user_id, course_id, enrollment_id, certificate_number, full_name, course_name, issued_date, expiry_date, validation_hash, status)
         VALUES ($1, $2, $3, $4, $5, $6, CURRENT_DATE, CURRENT_DATE + INTERVAL '2 years', $7, 'active') RETURNING *`,
        [userId, enrollment.course_id, enrollmentId, certNumber, displayName, course.title, hash]
      );
      return certRes.rows[0];
    });
  }

  static async verifyCertificate(number: string) {
    const res = await query('SELECT * FROM certificates WHERE certificate_number = $1', [number]);
    if (res.rows.length === 0) throw new AppError('Certificate not found', 404);
    return res.rows[0];
  }

  static async getDashboard(userId: string) {
    const completedRes = await query('SELECT COUNT(*) FROM enrollments WHERE user_id = $1 AND status = $2', [userId, 'completed']);
    const activeRes = await query('SELECT COUNT(*) FROM enrollments WHERE user_id = $1 AND status = $2', [userId, 'in_progress']);
    const avgRes = await query('SELECT AVG(score_percent) FROM quiz_attempts WHERE enrollment_id IN (SELECT id FROM enrollments WHERE user_id = $1)', [userId]);
    const recentCertsRes = await query(
      'SELECT * FROM certificates WHERE user_id = $1 ORDER BY issued_date DESC LIMIT 5', [userId]
    );
    return {
      coursesCompleted: parseInt(completedRes.rows[0].count, 10),
      activeCourses: parseInt(activeRes.rows[0].count, 10),
      averageScore: Math.round(avgRes.rows[0].avg || 0),
      recentCertificates: recentCertsRes.rows,
    };
  }
}
