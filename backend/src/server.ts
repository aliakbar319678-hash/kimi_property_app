import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import swaggerJsdoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';

import { config } from './config';
import { pool, initPostGIS, query } from './db';
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
import { applicationRouter } from './routes/application.routes';
import { jobRouter } from './routes/job.routes';
import { paymentRouter } from './routes/payment.routes';
import { initializeSocketHandlers } from './websocket/socket.handlers';
import { startCronJobs } from './cron/dailyJobs';

const allowedOrigins = [
  config.urls.web,
  config.urls.vendor,
  config.urls.admin,
  'http://localhost:8000',
  'http://127.0.0.1:8000',
  'http://localhost:8001',
  'http://127.0.0.1:8001',
  'http://localhost:5000',
  'http://127.0.0.1:5000',
  'http://192.168.6.106:5000'
];

const app = express();
const httpServer = createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: { origin: allowedOrigins, credentials: true }
});

function buildSwaggerSpec() {
  const mountedRouters = [
    { name: 'Auth', basePath: `/api/${config.apiVersion}/auth`, router: authRouter },
    { name: 'Users', basePath: `/api/${config.apiVersion}/users`, router: userRouter },
    { name: 'Properties', basePath: `/api/${config.apiVersion}/properties`, router: propertyRouter },
    { name: 'Leases', basePath: `/api/${config.apiVersion}/leases`, router: leaseRouter },
    { name: 'Finance', basePath: `/api/${config.apiVersion}/finance`, router: financeRouter },
    { name: 'Maintenance', basePath: `/api/${config.apiVersion}/maintenance`, router: maintenanceRouter },
    { name: 'Chat', basePath: `/api/${config.apiVersion}/chat`, router: chatRouter },
    { name: 'LMS', basePath: `/api/${config.apiVersion}/lms`, router: lmsRouter },
    { name: 'Admin', basePath: `/api/${config.apiVersion}/admin`, router: adminRouter },
    { name: 'Notifications', basePath: `/api/${config.apiVersion}/notifications`, router: notificationRouter },
    { name: 'Discussions', basePath: `/api/${config.apiVersion}/discussions`, router: discussionRouter },
    { name: 'Uploads', basePath: `/api/${config.apiVersion}/uploads`, router: uploadRouter },
    { name: 'Vendors', basePath: `/api/${config.apiVersion}/vendors`, router: vendorRouter },
    { name: 'Webhooks', basePath: `/api/${config.apiVersion}/webhooks`, router: webhookRouter },
    { name: 'Calendar', basePath: `/api/${config.apiVersion}/calendar`, router: calendarRouter },
    { name: 'AI', basePath: `/api/${config.apiVersion}/ai`, router: aiRouter },
    { name: 'Config', basePath: `/api/${config.apiVersion}/config`, router: configRouter },
    { name: 'Refunds', basePath: `/api/${config.apiVersion}/refunds`, router: refundRouter },
    { name: 'Escrows', basePath: `/api/${config.apiVersion}/escrows`, router: escrowRouter },
    { name: 'Payouts', basePath: `/api/${config.apiVersion}/payouts`, router: payoutRouter },
    { name: 'Staff', basePath: `/api/${config.apiVersion}/staff`, router: staffRouter },
    { name: 'Tickets', basePath: `/api/${config.apiVersion}/tickets`, router: ticketRouter },
    { name: 'Settings', basePath: `/api/${config.apiVersion}/settings`, router: platformRouter },
    { name: 'Applications', basePath: `/api/${config.apiVersion}/applications`, router: applicationRouter },
    { name: 'Jobs', basePath: `/api/${config.apiVersion}/jobs`, router: jobRouter },
    { name: 'Payments', basePath: `/api/${config.apiVersion}/payments`, router: paymentRouter }
  ];

  const paths: Record<string, any> = {};

  for (const group of mountedRouters) {
    for (const layer of (group.router as any).stack || []) {
      if (!layer.route) continue;

      const routePath = `${group.basePath}${layer.route.path === '/' ? '' : layer.route.path}`.replace(/\/+/g, '/');
      const methods = Object.entries(layer.route.methods as Record<string, boolean>)
        .filter(([, enabled]) => enabled)
        .map(([method]) => method.toLowerCase());

      for (const method of methods) {
        const openApiPath = routePath.replace(/:([a-zA-Z0-9_]+)/g, '{$1}');
        
        if (!paths[openApiPath]) {
          paths[openApiPath] = {};
        }

        const operationDetails: any = {
          summary: `${method.toUpperCase()} ${routePath}`,
          tags: [group.name],
          responses: {
            '200': { description: 'Success' },
            '400': { description: 'Bad request' },
            '401': { description: 'Unauthorized' },
            '404': { description: 'Not found' },
            '500': { description: 'Server error' }
          }
        };

        if (['post', 'put', 'patch'].includes(method)) {
          // Detect upload routes that accept files (multipart/form-data)
          if (openApiPath.includes('/uploads') || routePath.includes('/uploads')) {
            operationDetails.requestBody = {
              required: true,
              content: {
                'multipart/form-data': {
                  schema: {
                    type: 'object',
                    properties: {
                      file: { type: 'string', format: 'binary' }
                    },
                    required: ['file']
                  }
                }
              }
            };
          } else {
            operationDetails.requestBody = {
              required: false,
              content: {
                'application/json': {
                  schema: { type: 'object', additionalProperties: true, example: {} }
                }
              }
            };
          }
        }

        const pathParams = routePath.match(/:[a-zA-Z0-9_]+/g);
        if (pathParams) {
          operationDetails.parameters = pathParams.map(param => ({
            name: param.substring(1),
            in: 'path',
            required: true,
            schema: { type: 'string' }
          }));
        }

        paths[openApiPath][method] = operationDetails;
      }
    }
  }

  // Import detailed, fully typed swagger definitions for new APIs
  const { extraSwaggerPaths } = require('./config/swaggerExtras');
  Object.assign(paths, extraSwaggerPaths);

  return {
    openapi: '3.0.0',
    info: {
      title: 'PropAdmin API',
      version: '1.0.0',
      description: 'Swagger documentation for the PropAdmin backend API.'
    },
    servers: [{ url: `http://localhost:${config.port}` }],
    tags: mountedRouters.map((group) => ({ name: group.name })),
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        }
      }
    },
    security: [{ bearerAuth: [] }],
    paths
  };
}

const swaggerSpec = buildSwaggerSpec();
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
app.get('/api-docs.json', (req, res) => {
  res.json(swaggerSpec);
});

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({ origin: allowedOrigins, credentials: true }));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
import path from 'path';
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
app.use(`/api/${config.apiVersion}/payments`, paymentRouter);

app.post(`/api/${config.apiVersion}/test-live-charge`, async (req, res) => {
  try {
    const Stripe = require('stripe');
    const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
    const { token } = req.body;
    
    const charge = await stripe.charges.create({
      amount: 100, // $1.00
      currency: 'usd',
      source: token,
      description: 'Real-time Test Charge for proper working validation'
    });
    
    // Log to dashboard DB
    const { query } = require('./db');
    // Get a dummy payer (admin) just to satisfy foreign keys if needed
    const adminRes = await query(`SELECT id FROM users WHERE role = 'super_admin' LIMIT 1`);
    const adminId = adminRes.rows[0]?.id || null;
    
    await query(`
      INSERT INTO transactions (id, payer_id, payee_id, type, amount, currency, status, gateway, gateway_transaction_id, metadata)
      VALUES (gen_random_uuid(), $1, $1, 'application_fee', 1.00, 'usd', 'completed', 'stripe', $2, $3)
    `, [adminId, charge.id, JSON.stringify({ note: 'Manual Live Test', is_test: true })]);
    
    res.json({ success: true, message: 'Card successfully charged in real time!', charge });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
});
app.use(`/api/${config.apiVersion}/applications`, applicationRouter);
app.use(`/api/${config.apiVersion}/jobs`, jobRouter);

// Error handling
app.use(errorHandler);

// WebSocket initialization
initializeSocketHandlers(io);

// Start server
async function bootstrap() {
  await initPostGIS();
  const dbRes = await query('SELECT current_database()');
  console.log('🗄️  Connected to database:', dbRes.rows[0].current_database);
  startCronJobs();
  httpServer.listen(config.port, () => {
    console.log(`🚀 PropAdmin API running on port ${config.port}`);
    console.log(`📡 WebSocket server active`);
    console.log(`🌍 Environment: ${config.nodeEnv}`);
    console.log(`📚 Available routes: ${Object.keys(app._router?.stack || {}).length} middlewares loaded`);
  });
}

bootstrap().catch(console.error);

export { io };
