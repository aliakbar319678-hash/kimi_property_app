async function test() {
  try {
    const loginRes = await fetch('http://localhost:5000/api/v1/auth/login', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'landlord@test.com', password: 'password123' })
    });
    const loginData = await loginRes.json();
    const token = loginData.data.accessToken;
    console.log('Logged in', token.substring(0, 10));

    // Get units
    const dashRes = await fetch('http://localhost:5000/api/v1/properties/dashboard', {
      headers: { Authorization: `Bearer ${token}` }
    });
    const dashData = await dashRes.json();
    const propertyId = dashData.data.properties[0].id;
    
    const unitsRes = await fetch(`http://localhost:5000/api/v1/properties/${propertyId}/units`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    const unitsData = await unitsRes.json();
    const unitId = unitsData.data[0].id;

    // Get tenants
    const tenantsRes = await fetch('http://localhost:5000/api/v1/users?role=tenant', {
      headers: { Authorization: `Bearer ${token}` }
    });
    const tenantsData = await tenantsRes.json();
    const tenantId = tenantsData.data[0].id;

    console.log('Trying to create lease with unit:', unitId, 'tenant:', tenantId);

    const createRes = await fetch('http://localhost:5000/api/v1/leases', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
      body: JSON.stringify({
        tenantId: tenantId,
        unitId: unitId,
        startDate: '2025-01-01',
        endDate: '2026-01-01',
        rentAmount: 1500,
        depositAmount: 1500,
        paymentSchedule: 'monthly',
        autoRenew: false
      })
    });
    
    const createData = await createRes.json();
    console.log('Success:', createData);
  } catch (e) {
    console.error('Error:', e);
  }
}
test();
