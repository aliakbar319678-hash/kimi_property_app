const { Client } = require('pg');
const jwt = require('jsonwebtoken');
const fetch = require('node-fetch');

async function run() {
  const client = new Client({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });
  await client.connect();
  const res = await client.query("SELECT user_id FROM user_roles WHERE role = 'admin' LIMIT 1");
  const adminId = res.rows[0].user_id;
  await client.end();
  
  require('dotenv').config(); const secret = process.env.JWT_SECRET || 'default-secret-change-me';
  const token = jwt.sign(
    { userId: adminId, role: 'admin', email: 'admin@propadmin.io' },
    secret,
    { expiresIn: '1h' }
  );

  const payload = {
    display_name: 'Test Staff',
    email: 'teststaff' + Date.now() + '@example.com',
    password: 'Password123!',
    department: 'Support',
    permissions: {
      can_view_tickets: true
    }
  };

  const response = await fetch('http://localhost:5001/api/v1/staff', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(payload)
  });
  
  console.log(`Status: ${response.status} ${response.statusText}`);
  const text = await response.text();
  console.log(`Body: ${text}`);
}

run().catch(console.error);
