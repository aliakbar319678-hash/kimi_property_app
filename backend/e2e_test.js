// e2e_test.js — Full end-to-end API test: login → staff create → financial settings
const http = require('http');

function httpRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
        catch(e) { resolve({ status: res.statusCode, data: data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

async function post(path, payload, token) {
  const body = JSON.stringify(payload);
  const opts = {
    hostname: 'localhost',
    port: 5001,
    path,
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
      ...(token ? { 'Authorization': 'Bearer ' + token } : {})
    }
  };
  return httpRequest(opts, body);
}

async function put(path, payload, token) {
  const body = JSON.stringify(payload);
  const opts = {
    hostname: 'localhost',
    port: 5001,
    path,
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(body),
      'Authorization': 'Bearer ' + token
    }
  };
  return httpRequest(opts, body);
}

async function get(path, token) {
  return httpRequest({
    hostname: 'localhost', port: 5001, path, method: 'GET',
    headers: token ? { 'Authorization': 'Bearer ' + token } : {}
  });
}

async function run() {
  console.log('=== E2E API Test ===\n');

  // Step 1: Login
  console.log('1. Login test...');
  const loginRes = await post('/api/v1/auth/login', {
    email: 'admin@propadmin.io',
    password: 'Admin@1234'
  });
  console.log('   Status:', loginRes.status);
  if (loginRes.status !== 200) {
    console.log('   ERROR:', JSON.stringify(loginRes.data, null, 2));
    process.exit(1);
  }
  const token = loginRes.data.data.token;
  const roles = loginRes.data.data.user.roles;
  console.log('   ✓ Login success! Roles:', roles);
  console.log('   Token (preview):', token.substring(0, 60) + '...');

  // Step 2: GET /api/v1/staff
  console.log('\n2. List staff...');
  const staffListRes = await get('/api/v1/staff', token);
  console.log('   Status:', staffListRes.status);
  if (staffListRes.status === 200) {
    console.log('   ✓ Staff list OK — total:', staffListRes.data.meta?.total || 0);
    if (staffListRes.data.data) {
      staffListRes.data.data.forEach(s => console.log('     -', s.display_name, '(', s.email, ')', s.is_active ? 'active' : 'inactive'));
    }
  } else {
    console.log('   ERROR:', JSON.stringify(staffListRes.data));
  }

  // Step 3: POST /api/v1/staff (create staff)
  console.log('\n3. Create staff member...');
  const timestamp = Date.now();
  const createRes = await post('/api/v1/staff', {
    display_name: 'Test Staff Member',
    email: `test.staff.${timestamp}@propadmin.io`,
    password: 'Staff@1234',
    department: 'Support',
    permissions: {
      can_view_tickets: true,
      can_resolve_tickets: true,
      can_manage_payments: false,
      can_view_reports: true,
      can_manage_staff: false,
      can_manage_settings: false,
    }
  }, token);
  console.log('   Status:', createRes.status);
  if (createRes.status === 201) {
    console.log('   ✓ Staff created! ID:', createRes.data.data?.id);
    console.log('   Name:', createRes.data.data?.display_name);
  } else {
    console.log('   ERROR:', JSON.stringify(createRes.data));
  }

  // Step 4: GET /api/v1/settings/platform-fee
  console.log('\n4. Get platform financial settings...');
  const feeRes = await get('/api/v1/settings/platform-fee', token);
  console.log('   Status:', feeRes.status);
  if (feeRes.status === 200) {
    console.log('   ✓ Platform fee OK:', JSON.stringify(feeRes.data.data));
  } else {
    console.log('   ERROR:', JSON.stringify(feeRes.data));
  }

  // Step 5: PUT /api/v1/settings/platform-fee
  console.log('\n5. Save platform financial settings...');
  const feeUpdateRes = await put('/api/v1/settings/platform-fee', {
    platform_fee_percentage: 6.5,
    hold_period_days: 7
  }, token);
  console.log('   Status:', feeUpdateRes.status);
  if (feeUpdateRes.status === 200) {
    console.log('   ✓ Financial settings updated!', JSON.stringify(feeUpdateRes.data.data));
  } else {
    console.log('   ERROR:', JSON.stringify(feeUpdateRes.data));
  }

  // Step 6: PUT /api/v1/config (old config endpoint)
  console.log('\n6. Save config (admin_fee, late_fee_percent, currency)...');
  const configRes = await put('/api/v1/config', {
    admin_fee: 2.5,
    late_fee_percent: 12.0,
    currency: 'USD'
  }, token);
  console.log('   Status:', configRes.status);
  if (configRes.status === 200) {
    console.log('   ✓ Config updated!', JSON.stringify(configRes.data.data));
  } else {
    console.log('   ERROR:', JSON.stringify(configRes.data));
  }

  console.log('\n=== ALL TESTS COMPLETE ===');
  console.log('\nIf all tests passed, you can now:');
  console.log('1. Restart the Node backend (Ctrl+C then npm run dev)');
  console.log('2. Go to http://localhost:8000/login');
  console.log('3. Login with: admin@propadmin.io / Admin@1234');
  console.log('4. Visit Settings page — all forms should work');
}

run().catch(e => console.error('Fatal:', e.message));
