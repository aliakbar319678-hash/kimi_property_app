const http = require('http');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: 'postgresql://postgres:Aliakbar@localhost:5432/propadmin'
});

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

async function run() {
  try {
    // Get landlord
    const llRes = await pool.query("SELECT users.id FROM users JOIN user_roles ON users.id = user_roles.user_id WHERE role = 'landlord' LIMIT 1");
    const landlordId = llRes.rows[0].id;
    
    // Sign token manually
    const token = jwt.sign({ userId: landlordId, roles: ['landlord'] }, 'your-super-secret-jwt-key-min-32-chars', { expiresIn: '1h' });

    console.log("1. Registering tenant...");
    const regRes = await request('POST', '/api/v1/auth/register', {
      email: `testtenant_${Date.now()}@example.com`,
      password: "Password123!",
      role: "tenant"
    });
    console.log("Register response:", regRes.status, regRes.data.success);
    const tenantId = regRes.data.data.id;

    console.log("\n2. Fetching unit from DB...");
    const unitRes = await pool.query("SELECT id, property_id FROM units WHERE status = 'vacant' LIMIT 1");
    if (unitRes.rows.length === 0) throw new Error("No vacant units found");
    const vacantUnit = unitRes.rows[0];
    console.log("Found unit:", vacantUnit.id, "Property ID:", vacantUnit.property_id);

    console.log("\n3. Creating lease via API...");
    const leaseRes = await request('POST', '/api/v1/leases', {
      tenantId: tenantId,
      unitId: vacantUnit.id,
      propertyId: vacantUnit.property_id,
      startDate: new Date().toISOString(),
      endDate: new Date(Date.now() + 31536000000).toISOString(),
      rentAmount: Number(vacantUnit.rent) || 1000,
      securityDeposit: 1500,
      paymentSchedule: 'monthly',
      autoRenew: false
    }, token);
    console.log("Create Lease response:", leaseRes.status, leaseRes.data);
    
    process.exit(0);

  } catch(e) {
    console.error("Error:", e);
    process.exit(1);
  }
}

run();
