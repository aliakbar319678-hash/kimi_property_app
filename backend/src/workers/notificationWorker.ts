import { Queue, Worker } from 'bullmq';
import { config } from '../config';
import { NotificationService } from '../services/notification.service';
import IORedis from 'ioredis';

const connection = new IORedis(config.redisUrl, { maxRetriesPerRequest: null });
const notificationQueue = new Queue('notifications', { connection });

const worker = new Worker('notifications', async (job) => {
  const { userId, title, message, channels } = job.data;
  console.log(`Sending notification to ${userId} via ${channels?.join(',')}`);
  // In real implementation: call FCM, SendGrid, Twilio based on channels
  await NotificationService.create({ userId, type: 'system', title, message, channels: channels || ['in_app'] });
}, { connection });

export { notificationQueue };
