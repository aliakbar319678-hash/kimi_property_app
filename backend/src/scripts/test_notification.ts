import { NotificationService } from '../services/notification.service';

async function test() {
  try {
    console.log('Testing NotificationService.create with null userId...');
    await NotificationService.create({
      userId: null as any,
      type: 'lease',
      title: 'Lease Expiring Soon',
      message: `Your lease for Unit 101 expires in 30 days.`,
      priority: 'high',
      channels: ['in_app', 'email'],
    });
    console.log('Success (did not throw)!');
  } catch(e) {
    console.error('Failed as expected:', e);
  }
  process.exit(0);
}
test();
