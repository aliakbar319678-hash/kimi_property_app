const http = require('http');

function req(method, path, body, token) {
  return new Promise(resolve => {
    const data = body ? JSON.stringify(body) : null;
    const options = {
      hostname: 'localhost',
      port: 5000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: 'Bearer ' + token } : {}),
        ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {})
      }
    };
    const request = http.request(options, res => {
      let raw = '';
      res.on('data', chunk => raw += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(raw) }); } 
        catch { resolve({ status: res.statusCode, body: raw }); }
      });
    });
    request.on('error', e => resolve({ status: 0, body: e.message }));
    if (data) request.write(data);
    request.end();
  });
}

async function runTests() {
  let passed = 0, failed = 0;
  
  function assert(name, condition, details) {
    if (condition) {
      console.log(`✅ PASS: ${name}`);
      passed++;
    } else {
      console.log(`❌ FAIL: ${name}`);
      console.log(`   Details: ${JSON.stringify(details).substring(0, 200)}...`);
      failed++;
    }
  }

  console.log('--- STARTING ALL MODULES E2E TEST ---');

  // Login Super Admin
  const adminRes = await req('POST', '/api/v1/auth/login', { email: 'admin@propadmin.io', password: 'Admin123!' });
  const AT = adminRes.body.data?.accessToken;
  assert('Auth (Login Admin)', adminRes.status === 200, adminRes.status);

  // Login Landlord
  const landlordRes = await req('POST', '/api/v1/auth/login', { email: 'landlord@example.com', password: 'Admin123!' });
  const LT = landlordRes.body.data?.accessToken;
  assert('Auth (Login Landlord)', landlordRes.status === 200, landlordRes.status);

  // Users Module
  const userRes = await req('GET', '/api/v1/users/profile', null, LT);
  assert('Users Module (GET /profile)', userRes.status === 200 || userRes.status === 404, userRes.status); // 404 is fine if profile not complete, 500 is a bug

  // Properties Module
  const propRes = await req('GET', '/api/v1/properties/search', null, LT);
  assert('Properties Module (GET /search)', propRes.status === 200, propRes.status);

  // Leases Module
  const leaseRes = await req('GET', '/api/v1/leases/dashboard', null, LT);
  assert('Leases Module (GET /dashboard)', leaseRes.status === 200, leaseRes.status);

  // Finance Module
  const financeRes = await req('GET', '/api/v1/finance/dashboard', null, LT);
  assert('Finance Module (GET /dashboard)', financeRes.status === 200, financeRes.status);

  // Maintenance Module
  const maintRes = await req('GET', '/api/v1/maintenance/work-orders', null, LT);
  assert('Maintenance Module (GET /work-orders)', maintRes.status === 200, maintRes.status);

  // Chat Module
  const chatRes = await req('GET', '/api/v1/chat/rooms', null, LT);
  assert('Chat Module (GET /rooms)', chatRes.status === 200, chatRes.status);

  // Notifications Module
  const notifRes = await req('GET', '/api/v1/notifications', null, LT);
  assert('Notifications Module (GET /notifications)', notifRes.status === 200, notifRes.status);

  // Discussions Module
  const discRes = await req('GET', '/api/v1/discussions', null, LT);
  assert('Discussions Module (GET /discussions)', discRes.status === 200, discRes.status);

  // LMS Module
  const lmsRes = await req('GET', '/api/v1/lms/courses', null, LT);
  assert('LMS Module (GET /courses)', lmsRes.status === 200, lmsRes.status);

  // Vendors Module
  const vendorRes = await req('GET', '/api/v1/vendors/stats', null, AT);
  // Admin checking vendor stats might 403, as long as it's not 500
  assert('Vendors Module (GET /stats)', vendorRes.status !== 500, vendorRes.status);

  // Admin Module
  const adminLogsRes = await req('GET', '/api/v1/admin/audit-logs', null, AT);
  assert('Admin Module (GET /audit-logs)', adminLogsRes.status === 200, adminLogsRes.status);

  // Ads Module
  const adsRes = await req('GET', '/api/v1/ads/display', null, LT);
  assert('Ads Module (GET /ads/display)', adsRes.status === 200, adsRes.status);

  // Advanced Vendors Module
  const advVenRes = await req('GET', '/api/v1/vendors-advanced/directory', null, LT);
  assert('Advanced Vendors Module (GET /vendors-advanced/directory)', advVenRes.status === 200, advVenRes.status);

  // Reporting Module
  const reportRes = await req('GET', '/api/v1/reports/property-performance', null, LT);
  assert('Reporting Module (GET /reports/property-performance)', reportRes.status === 200 || reportRes.status === 403, reportRes.status);

  // Communications Module
  const commRes = await req('GET', '/api/v1/communications/email-templates', null, AT);
  assert('Communications Module (GET /communications/email-templates)', commRes.status === 200, commRes.status);

  console.log('--- TEST RESULTS ---');
  console.log(`Passed: ${passed} | Failed: ${failed}`);
  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
