const fetch = require('node-fetch');
const jwt = require('jsonwebtoken');

async function testStaffCreation() {
  const secret = 'your-super-secret-jwt-key-min-32-chars';
  // Generate a mock admin token
  const token = jwt.sign(
    { id: '123e4567-e89b-12d3-a456-426614174000', role: 'admin', email: 'admin@propadmin.io' },
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

  console.log('Sending request to http://localhost:5001/api/v1/staff with payload:', payload);

  try {
    const res = await fetch('http://localhost:5001/api/v1/staff', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(payload)
    });
    
    const text = await res.text();
    console.log('\n--- RESPONSE ---');
    console.log(`Status: ${res.status} ${res.statusText}`);
    console.log(`Body: ${text}`);
  } catch (err) {
    console.error('Request failed:', err);
  }
}

testStaffCreation();
