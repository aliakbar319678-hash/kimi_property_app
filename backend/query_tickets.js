const { Client } = require('pg');
const c = new Client({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });
c.connect().then(async () => {
  const u = await c.query("SELECT * FROM users WHERE email = 'john.doe@propadmin.com'");
  const userId = u.rows[0].id;
  console.log('UserID:', userId);
  const r1 = await c.query('SELECT * FROM tickets WHERE assigned_staff_id = $1', [userId]);
  console.log('Tickets:', r1.rows);
  const r2 = await c.query('SELECT * FROM support_tickets WHERE assigned_to LIKE $1', ['John Doe Manager%']);
  console.log('Support Tickets:', r2.rows);
  await c.end();
});
