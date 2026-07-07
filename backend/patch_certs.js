const { Client } = require('pg');
const client = new Client({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });
client.connect()
  .then(() => client.query(`
    UPDATE certificates c 
    SET full_name = u.display_name, 
        course_name = co.title 
    FROM users u, courses co 
    WHERE c.user_id = u.id 
    AND c.course_id = co.id 
    AND (c.full_name IS NULL OR c.course_name IS NULL)
  `))
  .then(res => { console.log('Updated rows:', res.rowCount); client.end(); })
  .catch(err => { console.error(err.message); client.end(); });
