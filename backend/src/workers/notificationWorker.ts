import { Queue, Worker } from 'bullmq';
import { config } from '../config';
import { NotificationService } from '../services/notification.service';

// Parse Redis URL into host/port for BullMQ ConnectionOptions
const redisUrl = new URL(config.redisUrl);
const redisConnection = {
  host: redisUrl.hostname,
  port: parseInt(redisUrl.port || '6379', 10),
};

const notificationQueue = new Queue('notifications', { connection: redisConnection });

const worker = new Worker('notifications', async (job) => {
  const { userId, title, message, channels } = job.data;
  console.log(`Sending notification to ${userId} via ${channels?.join(',')}`);
  // In real implementation: call FCM, SendGrid, Twilio based on channels
  await NotificationService.create({ userId, type: 'system', title, message, channels: channels || ['in_app'] });
}, { connection: redisConnection });

export { notificationQueue };
