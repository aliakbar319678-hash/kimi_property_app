const { Client } = require('pg');
const client = new Client({ connectionString: 'postgresql://postgres:1122@localhost:5432/mydatabase' });
client.connect().then(() => {
    return client.query(`UPDATE user_roles SET permissions = permissions || '{"can_manage_staff": true}'::jsonb WHERE role = 'staff' AND user_id IN (SELECT id FROM users WHERE email = 'itxtalha06@gmail.com')`);
}).then(res => {
    console.log(res.rowCount);
    client.end();
}).catch(err => {
    console.error(err);
});
