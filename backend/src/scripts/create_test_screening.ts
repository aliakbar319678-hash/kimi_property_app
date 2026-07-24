import dotenv from 'dotenv';
dotenv.config();
import { query, pool } from '../db';

async function main() {
  try {
    const propRes = await query('SELECT id FROM properties LIMIT 1');
    const userRes = await query('SELECT id FROM users LIMIT 1');

    if (propRes.rows.length === 0) {
      console.error('No property found in DB!');
      process.exit(1);
    }
    if (userRes.rows.length === 0) {
      console.error('No user found in DB!');
      process.exit(1);
    }

    const propertyId = propRes.rows[0].id;
    const tenantId = userRes.rows[0].id;

    const res = await query(
      `INSERT INTO screening_applications 
       (tenant_id, property_id, monthly_income, employment_status, credit_score_mock, background_status_mock, decision) 
       VALUES ($1, $2, $3, $4, $5, $6, 'pending') 
       RETURNING *`,
      [tenantId, propertyId, 9200, 'Senior Software Engineer', 748, 'APPROVED']
    );

    console.log('=== TEST SCREENING APPLICATION CREATED ===');
    console.log('SCREENING_UUID:', res.rows[0].id);
    console.log('PROPERTY_ID:', propertyId);
    console.log('TENANT_ID:', tenantId);
    console.log('MONTHLY_INCOME:', res.rows[0].monthly_income);
    console.log('CREDIT_SCORE:', res.rows[0].credit_score_mock);
    console.log('BACKGROUND_STATUS:', res.rows[0].background_status_mock);
    console.log('DECISION:', res.rows[0].decision);
    console.log('==========================================');
  } catch (err) {
    console.error('Error creating test screening application:', err);
  } finally {
    await pool.end();
  }
}

main();
