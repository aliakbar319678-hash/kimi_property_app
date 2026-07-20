const { query } = require('./src/db');
async function fix() {
  await query('UPDATE user_profiles SET onboarding_step = 1 WHERE onboarding_step = 5 AND onboarding_completed = false');
  console.log('Fixed onboarding steps');
  process.exit(0);
}
fix();
