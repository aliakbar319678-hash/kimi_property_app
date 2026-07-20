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
      console.log(`   Details: ${JSON.stringify(details)}`);
      failed++;
    }
  }

  console.log('--- STARTING COMPREHENSIVE API TESTS ---');

  // 1. Auth Tests
  const adminRes = await req('POST', '/api/v1/auth/login', { email: 'admin@propadmin.io', password: 'Admin123!' });
  assert('Admin Login', adminRes.status === 200 && adminRes.body.data.accessToken, adminRes.body);
  const AT = adminRes.body.data?.accessToken;

  const landlordRes = await req('POST', '/api/v1/auth/login', { email: 'landlord@example.com', password: 'Admin123!' });
  assert('Landlord Login', landlordRes.status === 200, landlordRes.body);
  const LT = landlordRes.body.data?.accessToken;

  const tenantRes = await req('POST', '/api/v1/auth/login', { email: 'tenant@example.com', password: 'Admin123!' });
  assert('Tenant Login', tenantRes.status === 200, tenantRes.body);
  const TT = tenantRes.body.data?.accessToken;

  // 2. Property CRUD
  const createPropRes = await req('POST', '/api/v1/properties', {
    name: 'Test E2E Property',
    addressLine1: '123 E2E St',
    city: 'Test City',
    stateProvince: 'TS',
    postalCode: '12345',
    countryCode: 'US',
    type: 'apartment',
    price: 1500
  }, LT);
  assert('Create Property (Landlord)', createPropRes.status === 201, createPropRes.body);
  const propertyId = createPropRes.body.data?.id;

  if (propertyId) {
    const getPropRes = await req('GET', `/api/v1/properties/${propertyId}`, null, LT);
    assert('Get Property by ID', getPropRes.status === 200, getPropRes.body);
  }

  // 3. Maintenance Work Order
  let workOrderId = null;
  if (propertyId) {
    const createWoRes = await req('POST', '/api/v1/maintenance/work-orders', {
      unitId: null, // Depending on schema, unitId might be required or nullable. We'll use a bogus or skip if it requires unit. Let's fetch units first.
      title: 'Fix Sink',
      description: 'Sink is leaking',
      category: 'plumbing',
      priority: 'high',
      currency: 'USD'
    }, LT);
    // Since we didn't provide a valid unit ID, it should gracefully fail with 404 or 400, not crash the server.
    assert('Create Work Order with Invalid Unit (Validation Check)', createWoRes.status === 404 || createWoRes.status === 400, createWoRes.body);
  }

  // 4. Role Switch API (The one we implemented!)
  const switchRes = await req('POST', '/api/v1/auth/switch-role', { role: 'landlord' }, LT);
  assert('Role Switch API (Landlord to Landlord)', switchRes.status === 200 && switchRes.body.data.activeRole === 'landlord', switchRes.body);

  // 5. Admin Dashboard
  const adminDashRes = await req('GET', '/api/v1/admin/dashboard', null, AT);
  assert('Admin Dashboard Data Fetch', adminDashRes.status === 200, adminDashRes.body);

  console.log('--- TEST RESULTS ---');
  console.log(`Passed: ${passed} | Failed: ${failed}`);
  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
