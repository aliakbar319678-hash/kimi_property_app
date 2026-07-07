const { Client } = require('pg');

async function search() {
  const client = new Client({
    connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase'
  });
  
  try {
    await client.connect();
    console.log('Connected to pg');
    
    // Get all tables
    const res = await client.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema='public'
    `);
    const tables = res.rows.map(r => r.table_name);
    
    for (const table of tables) {
      console.log(`Checking table: ${table}`);
      try {
        const data = await client.query(`SELECT * FROM "${table}"`);
        for (const row of data.rows) {
          for (const key in row) {
            const val = row[key];
            if (typeof val === 'string' && (val.includes('Test Discussion') || val.includes('Alex Thompson') || val.includes('Nice'))) {
              console.log(`Found in table ${table}, ID: ${row.id}, Col: ${key}, Val: ${val}`);
              
              // We should delete them as user requested
              if(row.id) {
                console.log(`DELETING from ${table} where id=${row.id}`);
                await client.query(`DELETE FROM "${table}" WHERE id=$1`, [row.id]);
              }
            }
          }
        }
      } catch (e) {
        // ignore errors for specific tables
      }
    }
  } catch (err) {
    console.error('Error', err);
  } finally {
    await client.end();
  }
}

search();
