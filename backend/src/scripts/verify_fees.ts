import { query } from '../db';

async function verify() {
  console.log("=== FEE VERIFICATION ===\n");

  // 1. Rent transactions
  console.log("--- RENT TRANSACTIONS (type='rent') ---");
  const r1 = await query(
    "SELECT id, type, amount, platform_fee_percentage, platform_fee_amount, net_amount FROM transactions WHERE type = 'rent' LIMIT 10"
  );
  console.table(r1.rows);

  // 2. Vendor hold transactions
  console.log("\n--- VENDOR HOLD TRANSACTIONS (type='vendor_hold') ---");
  const r1b = await query(
    "SELECT id, type, amount, platform_fee_percentage, platform_fee_amount, net_amount FROM transactions WHERE type = 'vendor_hold' LIMIT 10"
  );
  console.table(r1b.rows);

  // 3. Vendor payouts
  console.log("\n--- VENDOR PAYOUTS ---");
  const r2 = await query(
    "SELECT id, payee_role, amount, platform_fee_deducted FROM payouts WHERE payee_role = 'vendor' LIMIT 10"
  );
  console.table(r2.rows);

  // 4. Landlord payouts
  console.log("\n--- LANDLORD PAYOUTS ---");
  const r3 = await query(
    "SELECT id, payee_role, amount, platform_fee_deducted FROM payouts WHERE payee_role = 'landlord' LIMIT 10"
  );
  console.table(r3.rows);

  // 5. Platform settings
  console.log("\n--- PLATFORM SETTINGS ---");
  const r4 = await query("SELECT * FROM platform_settings LIMIT 1");
  console.table(r4.rows);

  // 6. Any remaining platform_fee transactions?
  console.log("\n--- REMAINING platform_fee TRANSACTIONS ---");
  const r5 = await query(
    "SELECT COUNT(*) as count FROM transactions WHERE type = 'platform_fee'"
  );
  console.log("Count:", r5.rows[0].count);

  process.exit(0);
}

verify().catch(err => {
  console.error("Verification failed:", err);
  process.exit(1);
});
