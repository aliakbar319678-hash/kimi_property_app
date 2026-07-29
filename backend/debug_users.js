const { Pool } = require('pg');
const pool = new Pool({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });

async function main() {
  const res = await pool.query(
    "SELECT u.id, u.email, u.display_name, ur.role FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id WHERE u.email IN ('john.doe@propadmin.com', 'admin@propadmin.io')"
  );
  console.log("=== Users & Roles ===");
  console.log(JSON.stringify(res.rows, null, 2));

  // Check tickets assigned to these users
  const johnId = res.rows.find(r => r.email === 'john.doe@propadmin.com')?.id;
  if (johnId) {
    const tickets = await pool.query(
      "SELECT id, title, status, priority, assigned_staff_id FROM tickets WHERE assigned_staff_id = $1",
      [johnId]
    );
    console.log("\n=== Tickets assigned to John Doe (id=" + johnId + ") ===");
    console.log(JSON.stringify(tickets.rows, null, 2));

    const supportTickets = await pool.query(
      "SELECT id, title, status, assigned_to FROM support_tickets WHERE assigned_to LIKE $1",
      ['John Doe%']
    );
    console.log("\n=== Support tickets assigned to 'John Doe%' ===");
    console.log(JSON.stringify(supportTickets.rows, null, 2));
  }

  // Check ALL tickets to see what's there
  const allTickets = await pool.query("SELECT id, title, status, assigned_staff_id FROM tickets LIMIT 20");
  console.log("\n=== All tickets (first 20) ===");
  console.log(JSON.stringify(allTickets.rows, null, 2));

  await pool.end();
}
main().catch(e => { console.error(e); process.exit(1); });
