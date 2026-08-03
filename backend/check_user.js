const { query } = require('./dist/db'); query('SELECT * FROM users WHERE email = ''aliakb6r9hhaghf9215@gmail.com''').then(r => console.log(r.rows)).finally(() => process.exit(0));
