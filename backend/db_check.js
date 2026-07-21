const http = require('http');

function request(method, path, data, token = null) {
  return new Promise((resolve, reject) => {
    const dataStr = data ? JSON.stringify(data) : '';
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': dataStr.length
      }
    };
    if (token) options.headers['Authorization'] = `Bearer ${token}`;

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          resolve({ status: res.statusCode, data: json });
        } catch(e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });
    req.on('error', reject);
    if (data) req.write(dataStr);
    req.end();
  });
}

const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: 'postgresql://postgres:Aliakbar@localhost:5432/propadmin'
});

async function run() {
  try {
    const llRes = await pool.query("SELECT users.id FROM users JOIN user_roles ON users.id = user_roles.user_id WHERE role = 'landlord' LIMIT 1");
    const landlordId = llRes.rows[0].id;
    const token = jwt.sign({ userId: landlordId, roles: ['landlord'] }, 'your-super-secret-jwt-key-min-32-chars', { expiresIn: '1h' });

    console.log("Fetching GET /api/v1/users/tenants...");
    const res = await request('GET', '/api/v1/users/tenants', null, token);
    console.log("Status:", res.status);
    console.log(JSON.stringify(res.data, null, 2));

  } catch(e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}

run();
