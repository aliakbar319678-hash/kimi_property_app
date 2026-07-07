const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgresql://postgres:Aliakbar@localhost:5432/propadmin'
});

async function checkUser() {
  try {
    await client.connect();
    
    const res = await client.query(`
      SELECT id, email, display_name, legal_first_name, legal_last_name, created_at 
      FROM users 
      WHERE email = 'aliakbar123@gmail.com'
    `);
    
    if (res.rows.length > 0) {
      console.log('✅ User Found in Database:');
      console.dir(res.rows[0], { depth: null, colors: true });
    } else {
      console.log('❌ User not found in database.');
    }
  } catch (err) {
    console.error('Error querying database:', err.message);
  } finally {
    await client.end();
  }
}

checkUser();
