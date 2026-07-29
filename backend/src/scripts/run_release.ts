import { releaseHeldPayments } from '../workers/releaseHeldPayments';

async function run() {
  console.log('Manually triggering releaseHeldPayments()...');
  try {
    await releaseHeldPayments();
    console.log('Finished manual release.');
  } catch (error) {
    console.error('Error during manual release:', error);
  }
  process.exit(0);
}

run();
