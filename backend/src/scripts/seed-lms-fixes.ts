import { query } from '../db';

async function seedLMSFixes() {
  console.log('Starting LMS Seed Fixes...');

  try {
    // 1. Get all courses
    const coursesRes = await query('SELECT id FROM courses');
    const courses = coursesRes.rows;
    console.log(`Found ${courses.length} courses to fix.`);

    for (const course of courses) {
      // 2. Ensure each course has valid modules with sample videos
      const modulesRes = await query('SELECT id FROM modules WHERE course_id = $1 ORDER BY sort_order', [course.id]);
      if (modulesRes.rows.length === 0) {
        // Create 2 modules if none exist
        await query(
          `INSERT INTO modules (course_id, title, description, content_type, content_url, sort_order, duration_minutes) 
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [course.id, 'Introduction to the Course', 'Basic overview and introduction.', 'video', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4', 1, 10]
        );
        await query(
          `INSERT INTO modules (course_id, title, description, content_type, content_url, sort_order, duration_minutes) 
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [course.id, 'Advanced Concepts', 'Diving deeper into the subject.', 'video', 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4', 2, 20]
        );
        console.log(`Created 2 default modules for course ${course.id}`);
      } else {
        // Update existing modules to have valid video urls if they are empty
        await query(
          `UPDATE modules SET content_url = 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4' 
           WHERE course_id = $1 AND (content_url IS NULL OR content_url = '')`,
          [course.id]
        );
        console.log(`Updated existing modules for course ${course.id}`);
      }

      // 3. Ensure each course has a proper Quiz
      const quizRes = await query('SELECT id FROM quizzes WHERE course_id = $1', [course.id]);
      
      const realQuestions = [
        {
          id: 'q1',
          text: 'What is the main objective of this course?',
          options: [
            { id: 'opt1', text: 'To learn basic concepts', is_correct: true },
            { id: 'opt2', text: 'To waste time', is_correct: false },
            { id: 'opt3', text: 'Nothing specific', is_correct: false },
            { id: 'opt4', text: 'To sleep', is_correct: false }
          ]
        },
        {
          id: 'q2',
          text: 'Which of the following is true about this topic?',
          options: [
            { id: 'opt1', text: 'It is very complex and unsolvable', is_correct: false },
            { id: 'opt2', text: 'It helps improve efficiency', is_correct: true },
            { id: 'opt3', text: 'It is outdated', is_correct: false },
            { id: 'opt4', text: 'None of the above', is_correct: false }
          ]
        },
        {
          id: 'q3',
          text: 'How should you apply these concepts?',
          options: [
            { id: 'opt1', text: 'Ignore them completely', is_correct: false },
            { id: 'opt2', text: 'Apply them step-by-step in practice', is_correct: true },
            { id: 'opt3', text: 'Only read them', is_correct: false },
            { id: 'opt4', text: 'Wait for someone else to do it', is_correct: false }
          ]
        }
      ];

      if (quizRes.rows.length === 0) {
        await query(
          `INSERT INTO quizzes (course_id, title, questions) VALUES ($1, $2, $3)`,
          [course.id, 'Final Certification Quiz', JSON.stringify(realQuestions)]
        );
        console.log(`Created new quiz for course ${course.id}`);
      } else {
        await query(
          `UPDATE quizzes SET questions = $1, title = $2 WHERE course_id = $3`,
          [JSON.stringify(realQuestions), 'Final Certification Quiz', course.id]
        );
        console.log(`Updated existing quiz for course ${course.id}`);
      }
    }

    console.log('LMS Seed Fixes Completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error during LMS Seed Fixes:', error);
    process.exit(1);
  }
}

seedLMSFixes();
