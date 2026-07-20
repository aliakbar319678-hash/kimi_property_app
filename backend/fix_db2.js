const { Pool } = require('pg');
const dotenv = require('dotenv');
dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

async function fix() {
  try {
    await pool.query('ALTER TABLE courses DROP CONSTRAINT courses_category_check;');
    await pool.query("ALTER TABLE courses ADD CONSTRAINT courses_category_check CHECK (category IN ('compliance','finance','maintenance','legal','strategy','fundamentals'));");
    console.log('Successfully added fundamentals to courses_category_check!');
  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}

fix();
