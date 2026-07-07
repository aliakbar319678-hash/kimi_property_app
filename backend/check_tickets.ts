import { query } from './src/db';

async function run() {
  try {
    await query(`
      CREATE TABLE IF NOT EXISTS support_ticket_updates (
          id SERIAL PRIMARY KEY,
          ticket_id INT REFERENCES support_tickets(id) ON DELETE CASCADE,
          user_name VARCHAR(100),
          action VARCHAR(50),
          note TEXT,
          created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `);
    console.log("Table created");
    process.exit(0);
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
}
run();
