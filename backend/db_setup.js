const { Client } = require('pg');

async function run() {
  const adminClient = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'Aliakbar',
    database: 'postgres'
  });

  try {
    await adminClient.connect();
    console.log('Connected to default postgres database.');

    // Check if propadmin database exists
    const dbCheck = await adminClient.query("SELECT 1 FROM pg_database WHERE datname = 'propadmin'");
    if (dbCheck.rows.length === 0) {
      console.log("Database 'propadmin' does not exist. Creating it...");
      await adminClient.query("CREATE DATABASE propadmin");
      console.log("Database 'propadmin' created successfully.");
    } else {
      console.log("Database 'propadmin' already exists.");
    }
  } catch (err) {
    console.error('Error setting up database:', err);
    process.exit(1);
  } finally {
    await adminClient.end();
  }

  // Connect to propadmin database to check and install extensions
  const propClient = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: 'Aliakbar',
    database: 'propadmin'
  });

  try {
    await propClient.connect();
    console.log("Connected to 'propadmin' database.");

    // Check/create postgis
    try {
      await propClient.query("CREATE EXTENSION IF NOT EXISTS postgis");
      console.log("Extension 'postgis' is ready.");
    } catch (e) {
      console.error("Failed to enable 'postgis' extension:", e.message);
    }

    // Check/create uuid-ossp
    try {
      await propClient.query("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"");
      console.log("Extension 'uuid-ossp' is ready.");
    } catch (e) {
      console.error("Failed to enable 'uuid-ossp' extension:", e.message);
    }

  } catch (err) {
    console.error('Error configuring extensions:', err);
    process.exit(1);
  } finally {
    await propClient.end();
  }
}

run();
