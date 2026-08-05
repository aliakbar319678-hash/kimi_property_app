import { query } from './src/db';

async function check() {
  const res = await query('SELECT id, course_name, course_id FROM certificates');
  
  const courses = await query('SELECT id, title FROM courses');
  for (const c of res.rows) {
      if (c.course_name === 'Course Name' || c.course_name === null) {
          const course = courses.rows.find(x => x.id === c.course_id);
          if (course) {
              await query('UPDATE certificates SET course_name = $1 WHERE id = $2', [course.title, c.id]);
              console.log('Updated certificate', c.id, 'to', course.title);
          }
      }
  }
  process.exit(0);
}
check();
