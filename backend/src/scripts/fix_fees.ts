import { query } from '../db';

async function fix() {
    console.log("=== Fee Correction Script ===");
    console.log(`Started at: ${new Date().toISOString()}\n`);

    // 1. Vendor: Update holding transactions → 4%
    const r1 = await query(`
        UPDATE transactions 
        SET platform_fee_percentage = 4.00, 
            platform_fee_amount = amount * 0.04, 
            net_amount = amount - (amount * 0.04) 
        WHERE type = 'vendor_hold'
    `);
    console.log(`[1] Vendor transactions (vendor_hold) updated: ${r1.rowCount} rows`);

    // 2. Vendor: Update payouts → 4%
    const r2 = await query(`
        UPDATE payouts 
        SET platform_fee_deducted = amount * 0.04 
        WHERE payee_role = 'vendor'
    `);
    console.log(`[2] Vendor payouts updated: ${r2.rowCount} rows`);

    // 3. Landlord: Update payouts → 0% (no fee)
    const r3 = await query(`
        UPDATE payouts 
        SET platform_fee_deducted = 0 
        WHERE payee_role = 'landlord'
    `);
    console.log(`[3] Landlord payouts updated: ${r3.rowCount} rows`);

    // 4. Landlord: Update rent transactions → 0% (no fee)
    const r4 = await query(`
        UPDATE transactions 
        SET platform_fee_amount = 0, 
            platform_fee_percentage = 0, 
            net_amount = amount 
        WHERE type = 'rent'
    `);
    console.log(`[4] Landlord rent transactions updated: ${r4.rowCount} rows`);

    // 5. Delete stray platform_fee transactions created for rent
    const r5 = await query(`
        DELETE FROM transactions 
        WHERE type = 'platform_fee'
    `);
    console.log(`[5] Stray platform_fee transactions deleted: ${r5.rowCount} rows`);

    // Summary
    console.log("\n=== SUMMARY ===");
    console.log(`  Vendor vendor_hold txns fixed:   ${r1.rowCount}`);
    console.log(`  Vendor payouts fixed:            ${r2.rowCount}`);
    console.log(`  Landlord payouts fixed:          ${r3.rowCount}`);
    console.log(`  Landlord rent txns fixed:        ${r4.rowCount}`);
    console.log(`  Stray platform_fee txns deleted: ${r5.rowCount}`);
    console.log(`  TOTAL rows affected:             ${(r1.rowCount||0)+(r2.rowCount||0)+(r3.rowCount||0)+(r4.rowCount||0)+(r5.rowCount||0)}`);
    console.log(`\nCompleted at: ${new Date().toISOString()}`);
    process.exit(0);
}

fix().catch(err => {
    console.error("Script failed:", err);
    process.exit(1);
});
