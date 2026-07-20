import { Queue, Worker } from 'bullmq';
import { config } from '../config';
import { ExportService } from '../services/export.service';
import { NotificationService } from '../services/notification.service';
import { query } from '../db';

// Parse Redis URL into host/port for BullMQ ConnectionOptions
const redisUrl = new URL(config.redisUrl);
const redisConnection = {
  host: redisUrl.hostname,
  port: parseInt(redisUrl.port || '6379', 10),
};

const exportQueue = new Queue('exports', { connection: redisConnection });

const worker = new Worker('exports', async (job) => {
  console.log(`Processing export job ${job.id}`);
  await ExportService.processJob(job.data.jobId);
  // Notify user
  const jobRes = await query('SELECT user_id FROM export_jobs WHERE id = $1', [job.data.jobId]);
  if (jobRes.rows.length > 0) {
    await NotificationService.create({
      userId: jobRes.rows[0].user_id,
      type: 'system',
      title: 'Export Ready',
      message: `Your ${job.data.jobType} export is ready for download.`,
      actionUrl: `/api/v1/exports/${job.data.jobId}/download`,
      actionType: 'download',
      priority: 'normal',
      channels: ['in_app', 'email'],
    });
  }
}, { connection: redisConnection });

worker.on('completed', (job) => console.log(`Export job ${job.id} completed`));
worker.on('failed', (job, err) => console.error(`Export job ${job?.id} failed`, err));

export { exportQueue };
