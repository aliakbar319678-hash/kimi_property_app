const { Pool } = require('pg');
const dotenv = require('dotenv');
dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function seedModuleAndQuiz() {
  try {
    // 1. Get a course
    const courseRes = await pool.query("SELECT id FROM courses LIMIT 1");
    if (courseRes.rows.length === 0) {
      console.log('No courses found to attach module to.');
      process.exit(0);
    }
    const courseId = courseRes.rows[0].id;

    // 2. Insert Module
    const moduleRes = await pool.query(
      `INSERT INTO modules (course_id, title, sort_order, content_type, duration_minutes) 
       VALUES ($1, 'Module 1: Intro', 1, 'quiz', 30) RETURNING id`,
      [courseId]
    );
    const moduleId = moduleRes.rows[0].id;

    // 3. Insert Quiz
    const questions = [
      {
        id: "q1",
        text: "What is fair housing?",
        options: [
          { id: "o1", text: "Treating everyone equally", is_correct: true },
          { id: "o2", text: "A scam", is_correct: false }
        ]
      }
    ];

    const quizRes = await pool.query(
      `INSERT INTO quizzes (module_id, title, questions) 
       VALUES ($1, 'Fair Housing Quiz', $2) RETURNING id`,
      [moduleId, JSON.stringify(questions)]
    );
    const quizId = quizRes.rows[0].id;

    // Update module with quiz_id
    await pool.query('UPDATE modules SET quiz_id = $1 WHERE id = $2', [quizId, moduleId]);

    console.log(`Successfully added Module!`);
    console.log(`Module ID: ${moduleId}`);
    console.log(`Quiz ID: ${quizId}`);
  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}

seedModuleAndQuiz();
