import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import swaggerUi from 'swagger-ui-express';
import fs from 'fs';
import path from 'path';

import { config } from './config';
import { pool, initPostGIS } from './db';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import { authRouter } from './routes/auth.routes';
import { userRouter } from './routes/user.routes';
import { propertyRouter } from './routes/property.routes';
import { leaseRouter } from './routes/lease.routes';
import { financeRouter } from './routes/finance.routes';
import { maintenanceRouter } from './routes/maintenance.routes';
import { chatRouter } from './routes/chat.routes';
import { lmsRouter } from './routes/lms.routes';
import { adminRouter } from './routes/admin.routes';
import { notificationRouter } from './routes/notification.routes';
import { discussionRouter } from './routes/discussion.routes';
import { uploadRouter } from './routes/upload.routes';
import { vendorRouter } from './routes/vendor.routes';
import { webhookRouter } from './routes/webhook.routes';
import { calendarRouter } from './routes/calendar.routes';
import { aiRouter } from './routes/ai.routes';
import { configRouter } from './routes/config.routes';
import { refundRouter } from './routes/refund.routes';
import { escrowRouter } from './routes/escrow.routes';
import { payoutRouter } from './routes/payout.routes';
import { staffRouter } from './routes/staff.routes';
import { ticketRouter } from './routes/ticket.routes';
import { platformRouter } from './routes/platform.routes';
import { initializeSocketHandlers } from './websocket/socket.handlers';
import { startCronJobs } from './cron/dailyJobs';

const allowedOrigins = [
  config.urls.web,
  config.urls.vendor,
  config.urls.admin,
  'http://localhost:8000',
  'http://127.0.0.1:8000',
  'http://localhost:8001',
  'http://127.0.0.1:8001'
];

const app = express();
const httpServer = createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: { origin: allowedOrigins, credentials: true }
});

// Security middleware
app.use(helmet());
app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));
app.use(requestLogger);

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use(`/api/${config.apiVersion}`, apiLimiter);

// Raw body for Stripe webhooks (must be before express.json)
app.use('/api/v1/webhooks/stripe', express.raw({ type: 'application/json' }));

// Swagger Documentation
let swaggerPath = path.join(__dirname, '../swagger-output.json');
if (!fs.existsSync(swaggerPath)) {
  swaggerPath = path.join(__dirname, './swagger-output.json');
}
if (!fs.existsSync(swaggerPath)) {
  swaggerPath = path.join(__dirname, '../../swagger-output.json');
}
try {
  const swaggerDocument = JSON.parse(fs.readFileSync(swaggerPath, 'utf8'));
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
  console.log('✅ Swagger UI registered from swagger-output.json');
} catch (e: any) {
  console.error('⚠️  Failed to load Swagger JSON:', e.message);
}

// Health check
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  } catch (e) {
    res.status(503).json({ status: 'error', message: 'Database unavailable' });
  }
});

// API Routes
app.use(`/api/${config.apiVersion}/auth`, authRouter);
app.use(`/api/${config.apiVersion}/users`, userRouter);
app.use(`/api/${config.apiVersion}/properties`, propertyRouter);
app.use(`/api/${config.apiVersion}/leases`, leaseRouter);
app.use(`/api/${config.apiVersion}/finance`, financeRouter);
app.use(`/api/${config.apiVersion}/maintenance`, maintenanceRouter);
app.use(`/api/${config.apiVersion}/chat`, chatRouter);
app.use(`/api/${config.apiVersion}/lms`, lmsRouter);
app.use(`/api/${config.apiVersion}/admin`, adminRouter);
app.use(`/api/${config.apiVersion}/notifications`, notificationRouter);
app.use(`/api/${config.apiVersion}/discussions`, discussionRouter);
app.use(`/api/${config.apiVersion}/uploads`, uploadRouter);
app.use(`/api/${config.apiVersion}/vendors`, vendorRouter);
app.use(`/api/${config.apiVersion}/webhooks`, webhookRouter);
app.use(`/api/${config.apiVersion}/calendar`, calendarRouter);
app.use(`/api/${config.apiVersion}/ai`, aiRouter);
app.use(`/api/${config.apiVersion}/config`, configRouter);
app.use(`/api/${config.apiVersion}/refunds`, refundRouter);
app.use(`/api/${config.apiVersion}/escrows`, escrowRouter);
app.use(`/api/${config.apiVersion}/payouts`, payoutRouter);
app.use(`/api/${config.apiVersion}/staff`, staffRouter);
app.use(`/api/${config.apiVersion}/tickets`, ticketRouter);
app.use(`/api/${config.apiVersion}/settings`, platformRouter);

// Error handling
app.use(errorHandler);

// WebSocket initialization
initializeSocketHandlers(io);

// Start server
async function bootstrap() {
  await initPostGIS();
  startCronJobs();
  httpServer.listen(config.port, '0.0.0.0', () => {
    console.log(`🚀 PropAdmin API running on port ${config.port}`);
    console.log(`📡 WebSocket server active`);
    console.log(`🌍 Environment: ${config.nodeEnv}`);
    console.log(`📚 Available routes: ${Object.keys(app._router?.stack || {}).length} middlewares loaded`);
  });
}

bootstrap().catch(console.error);

export { io };
