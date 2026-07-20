import { AdService } from '../services/ad.service';
import { pool, initPostGIS } from '../db';

async function testAds() {
  await initPostGIS();

  console.log('\n--- 1. Testing Admin get all ads ---');
  const allAds = await AdService.getAll();
  console.log(`Found ${allAds.length} total ads.`);

  console.log('\n--- 2. Testing Global Ads (No location, tenant role) ---');
  const globalAds = await AdService.getDisplayAds({ roles: ['tenant'] });
  console.log(`Global ads for tenant: ${globalAds.length}`);
  globalAds.forEach(a => console.log(` - ${a.title}`));

  console.log('\n--- 3. Testing NYC Ads (lat: 40.71, lng: -74.00, vendor role) ---');
  const nycVendors = await AdService.getDisplayAds({ lat: 40.71, lng: -74.00, roles: ['vendor'] });
  console.log(`NYC ads for vendor: ${nycVendors.length}`);
  nycVendors.forEach(a => console.log(` - ${a.title}`));

  console.log('\n--- 4. Testing London Ads (lat: 51.50, lng: -0.12, tenant role) ---');
  const lonTenants = await AdService.getDisplayAds({ lat: 51.50, lng: -0.12, roles: ['tenant'] });
  console.log(`London ads for tenant: ${lonTenants.length}`);
  lonTenants.forEach(a => console.log(` - ${a.title}`));

  console.log('\n--- 5. Testing Empty Role overlap (lat: 40.71, lng: -74.00, invalid role) ---');
  const invalidRole = await AdService.getDisplayAds({ lat: 40.71, lng: -74.00, roles: ['xyz'] });
  console.log(`Ads for invalid role: ${invalidRole.length}`);
  invalidRole.forEach(a => console.log(` - ${a.title}`));

  await pool.end();
}

testAds().catch(console.error);
