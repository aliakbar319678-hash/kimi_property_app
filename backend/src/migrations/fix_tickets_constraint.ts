import { query } from '../db';

async function main() {
  await query(`ALTER TABLE tickets DROP CONSTRAINT IF EXISTS tickets_category_check`);
  await query(`
    ALTER TABLE tickets 
    ADD CONSTRAINT tickets_category_check 
    CHECK (category IN ('general','payment_hold','maintenance','billing','access','other','kyc_verification','account_suspended','technical'))
  `);
  console.log('Successfully updated tickets category constraint!');
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
