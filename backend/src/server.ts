import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import { createServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';

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
import { adRouter } from './routes/ad.routes';
import { screeningRouter } from './routes/screening.routes';
import { moveRouter } from './routes/move.routes';
import { lateRouter } from './routes/late.routes';
import { vendorAdvancedRouter } from './routes/vendor_advanced.routes';
import { communicationRouter } from './routes/communication.routes';
import { reportRouter } from './routes/report.routes';
import { marketingRouter } from './routes/marketing.routes';
import { applicationRouter } from './routes/application.routes';
import { tenantRouter } from './routes/tenant.routes';
import { initializeSocketHandlers } from './websocket/socket.handlers';
import { startCronJobs } from './cron/dailyJobs';
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';

const app = express();
const httpServer = createServer(app);
const io = new SocketIOServer(httpServer, {
  cors: { origin: true, credentials: true }
});

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false,
}));

import path from 'path';

// Allow CORS from any origin for ease of development and testing
app.use(cors({
  origin: true,
  credentials: true,
}));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
app.use(requestLogger);

// Rate limiting — higher in dev to avoid test throttling
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: config.nodeEnv === 'production' ? 100 : 500,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => {
    // Skip rate limiting for localhost requests in dev (test runners, Postman, Swagger)
    const ip = req.ip || req.socket.remoteAddress || '';
    return config.nodeEnv !== 'production' && (ip === '::1' || ip === '127.0.0.1' || ip.startsWith('::ffff:127.'));
  },
});
app.use(`/api/${config.apiVersion}`, apiLimiter);

// Raw body for Stripe webhooks (must be before express.json)
app.use('/api/v1/webhooks/stripe', express.raw({ type: 'application/json' }));

// Live API Console
app.get('/', (req, res) => {
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>PropAdmin API Console</title>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
      <style>
        :root {
          --bg-primary: #0f172a;
          --bg-secondary: #1e293b;
          --accent: #3b82f6;
          --accent-hover: #2563eb;
          --text-main: #f8fafc;
          --text-muted: #94a3b8;
          --success: #10b981;
          --error: #ef4444;
          --border: #334155;
          --warn: #f59e0b;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
          font-family: 'Inter', sans-serif;
          background-color: var(--bg-primary);
          color: var(--text-main);
          padding: 2rem;
          min-height: 100vh;
        }
        .container { max-width: 1280px; margin: 0 auto; }
        header { margin-bottom: 2rem; text-align: center; }
        h1 {
          font-size: 2.2rem;
          font-weight: 700;
          background: linear-gradient(135deg, #60a5fa, #3b82f6);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          margin-bottom: 0.5rem;
        }
        p.subtitle { color: var(--text-muted); font-size: 1rem; }
        .grid {
          display: grid;
          grid-template-columns: 420px 1fr;
          gap: 2rem;
          align-items: start;
        }
        .left-col { display: flex; flex-direction: column; gap: 1.5rem; }
        .card {
          background-color: var(--bg-secondary);
          border: 1px solid var(--border);
          border-radius: 12px;
          padding: 1.5rem;
          box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
        }
        h2 {
          font-size: 1.1rem;
          font-weight: 600;
          margin-bottom: 1rem;
          border-bottom: 1px solid var(--border);
          padding-bottom: 0.5rem;
          color: #93c5fd;
        }
        h3 {
          font-size: 0.8rem;
          font-weight: 600;
          color: var(--text-muted);
          text-transform: uppercase;
          letter-spacing: 0.08em;
          margin: 1rem 0 0.5rem;
        }
        h3:first-child { margin-top: 0; }
        label { display: block; margin-bottom: 0.5rem; font-size: 0.875rem; color: var(--text-muted); font-weight: 500; }
        .token-display {
          background-color: var(--bg-primary);
          border: 1px solid var(--border);
          padding: 0.75rem;
          border-radius: 6px;
          font-family: monospace;
          font-size: 0.75rem;
          word-break: break-all;
          max-height: 80px;
          overflow-y: auto;
          color: #38bdf8;
          margin-top: 0.5rem;
        }
        .login-buttons { display: grid; grid-template-columns: 1fr 1fr; gap: 0.4rem; margin-bottom: 1rem; }
        .btn-login {
          padding: 0.55rem 0.5rem;
          background-color: transparent;
          border: 1px solid var(--border);
          color: var(--text-muted);
          border-radius: 6px;
          font-weight: 600;
          font-size: 0.8rem;
          cursor: pointer;
          transition: all 0.2s;
          text-align: center;
        }
        .btn-login:hover { border-color: var(--accent); color: #93c5fd; background: rgba(59,130,246,0.08); }
        .btn-login.active { border-color: var(--accent); background: rgba(59,130,246,0.15); color: #93c5fd; }
        .api-endpoints { display: flex; flex-direction: column; gap: 0.35rem; }
        .api-item {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 0.5rem 0.75rem;
          background-color: var(--bg-primary);
          border: 1px solid var(--border);
          border-radius: 6px;
          font-size: 0.82rem;
          gap: 0.5rem;
        }
        .api-item-left { display: flex; align-items: center; gap: 0.4rem; flex-wrap: wrap; min-width: 0; }
        .api-path { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px; color: var(--text-main); }
        .method {
          font-size: 0.68rem;
          font-weight: 700;
          padding: 0.15rem 0.4rem;
          border-radius: 3px;
          flex-shrink: 0;
        }
        .method.get { background-color: rgba(16, 185, 129, 0.2); color: #34d399; }
        .method.post { background-color: rgba(59, 130, 246, 0.2); color: #60a5fa; }
        .method.put { background-color: rgba(245, 158, 11, 0.2); color: #fbbf24; }
        .method.delete { background-color: rgba(239, 68, 68, 0.2); color: #f87171; }
        .role-badge {
          font-size: 0.62rem;
          font-weight: 600;
          padding: 0.1rem 0.35rem;
          border-radius: 3px;
          flex-shrink: 0;
          background: rgba(139, 92, 246, 0.2);
          color: #c4b5fd;
          white-space: nowrap;
        }
        .role-badge.public { background: rgba(16, 185, 129, 0.15); color: #6ee7b7; }
        .role-badge.any { background: rgba(148, 163, 184, 0.15); color: #94a3b8; }
        .role-badge.admin { background: rgba(239, 68, 68, 0.2); color: #fca5a5; }
        .role-badge.super { background: rgba(239, 68, 68, 0.3); color: #f87171; }
        .role-badge.vendor { background: rgba(245, 158, 11, 0.2); color: #fcd34d; }
        .role-badge.tenant { background: rgba(16, 185, 129, 0.2); color: #34d399; }
        .role-badge.landlord { background: rgba(59, 130, 246, 0.2); color: #93c5fd; }
        .endpoint-btn {
          background-color: var(--accent);
          color: white;
          border: none;
          padding: 0.3rem 0.65rem;
          border-radius: 4px;
          font-size: 0.75rem;
          font-weight: 500;
          cursor: pointer;
          flex-shrink: 0;
          transition: background 0.15s;
        }
        .endpoint-btn:hover { background-color: var(--accent-hover); }
        .response-container { display: flex; flex-direction: column; height: 100%; }
        .response-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; }
        .status-badge { padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.85rem; font-weight: 600; }
        .status-success { background-color: rgba(16, 185, 129, 0.2); color: #34d399; }
        .status-error { background-color: rgba(239, 68, 68, 0.2); color: #f87171; }
        .active-user-badge {
          display: inline-block;
          padding: 0.2rem 0.6rem;
          border-radius: 20px;
          font-size: 0.75rem;
          font-weight: 600;
          background: rgba(59,130,246,0.2);
          color: #93c5fd;
          margin-bottom: 0.75rem;
        }
        pre {
          background-color: var(--bg-primary);
          border: 1px solid var(--border);
          border-radius: 8px;
          padding: 1.5rem;
          overflow: auto;
          font-family: monospace;
          font-size: 0.85rem;
          flex-grow: 1;
          min-height: 500px;
          max-height: 700px;
          color: #34d399;
          white-space: pre-wrap;
          word-break: break-word;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <header>
          <h1>PropAdmin Live API Console</h1>
          <p class="subtitle">Authenticate and test all 50+ live backend endpoints</p>
        </header>
        
        <div class="grid">
          <div class="left-col">
            <div class="card">
              <h2>1. Login / Authenticate</h2>
              <div class="login-buttons">
                <button class="btn-login" id="btn-superadmin" onclick="loginAs('admin@propadmin.io', this)">🛡️ Super Admin</button>
                <button class="btn-login" id="btn-landlord" onclick="loginAs('landlord@example.com', this)">🏠 Landlord</button>
                <button class="btn-login" id="btn-tenant" onclick="loginAs('tenant@example.com', this)">👤 Tenant</button>
                <button class="btn-login" id="btn-vendor" onclick="loginAs('vendor@example.com', this)">🔧 Vendor</button>
              </div>
              <div id="active-user-badge" class="active-user-badge" style="display:none"></div>
              <label>JWT Token</label>
              <div id="token-display" class="token-display">No token yet. Click a login button above.</div>
            </div>
            
            <div class="card">
              <h2>2. Call Live APIs</h2>
              <div class="api-endpoints">

                <h3>🌐 System</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/health</span><span class="role-badge public">PUBLIC</span></div>
                  <button class="endpoint-btn" onclick="callApi('/health', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/auth/me</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/auth/me', 'GET')">Run</button>
                </div>

                <h3>🛡️ Admin (super_admin / admin only)</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/admin/dashboard</span><span class="role-badge admin">ADMIN+</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/admin/dashboard', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/admin/audit-logs</span><span class="role-badge admin">ADMIN+</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/admin/audit-logs', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/admin/verification-queue</span><span class="role-badge admin">ADMIN+</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/admin/verification-queue', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/admin/system-health</span><span class="role-badge admin">ADMIN+</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/admin/system-health', 'GET')">Run</button>
                </div>

                <h3>🏢 Properties</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/properties/search</span><span class="role-badge public">PUBLIC</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/properties/search', 'GET')">Run</button>
                </div>

                <h3>📝 Leases</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/leases/dashboard</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/leases/dashboard', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/leases/expiring-soon</span><span class="role-badge landlord">LANDLORD</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/leases/expiring-soon', 'GET')">Run</button>
                </div>

                <h3>💰 Finance</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/finance/dashboard</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/finance/dashboard', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/finance/vendor/earnings</span><span class="role-badge vendor">VENDOR</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/finance/vendor/earnings', 'GET')">Run</button>
                </div>

                <h3>🔧 Maintenance</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/maintenance/work-orders</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/maintenance/work-orders', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/maintenance/vendor/jobs</span><span class="role-badge vendor">VENDOR</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/maintenance/vendor/jobs', 'GET')">Run</button>
                </div>

                <h3>🎓 LMS</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/lms/courses</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/lms/courses', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/lms/certificates</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/lms/certificates', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/lms/dashboard</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/lms/dashboard', 'GET')">Run</button>
                </div>

                <h3>💬 Chat & Notifications</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/chat/rooms</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/chat/rooms', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/notifications</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/notifications', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/notifications/unread-count</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/notifications/unread-count', 'GET')">Run</button>
                </div>

                <h3>🔨 Vendor</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/vendors/my-bids</span><span class="role-badge vendor">VENDOR</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/vendors/my-bids', 'GET')">Run</button>
                </div>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/vendors/stats</span><span class="role-badge vendor">VENDOR</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/vendors/stats', 'GET')">Run</button>
                </div>

                <h3>💬 Discussions</h3>
                <div class="api-item">
                  <div class="api-item-left"><span class="method get">GET</span><span class="api-path">/api/v1/discussions</span><span class="role-badge any">ANY</span></div>
                  <button class="endpoint-btn" onclick="callApi('/api/v1/discussions', 'GET')">Run</button>
                </div>
              </div>
            </div>
          </div>
          
          <div class="card" style="display: flex; flex-direction: column; position: sticky; top: 2rem;">
            <div class="response-container">
              <div class="response-header">
                <h2>3. JSON Response</h2>
                <div id="status-badge" class="status-badge" style="display: none;"></div>
              </div>
              <pre id="response-output">Login first, then click any API endpoint on the left to see the live response.</pre>
            </div>
          </div>
        </div>
      </div>

      <script>
        let jwtToken = '';

        async function loginAs(email, btn) {
          const output = document.getElementById('response-output');
          const tokenDisplay = document.getElementById('token-display');
          const statusBadge = document.getElementById('status-badge');
          const userBadge = document.getElementById('active-user-badge');
          
          // Highlight active button
          document.querySelectorAll('.btn-login').forEach(b => b.classList.remove('active'));
          if (btn) btn.classList.add('active');
          
          output.textContent = 'Authenticating as ' + email + '...';
          
          try {
            const response = await fetch('/api/v1/auth/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email: email, password: 'Admin123!' })
            });
            
            const data = await response.json();
            
            statusBadge.style.display = 'block';
            statusBadge.className = response.ok ? 'status-badge status-success' : 'status-badge status-error';
            statusBadge.textContent = response.ok ? 'SUCCESS (' + response.status + ')' : 'ERROR (' + response.status + ')';
            
            output.textContent = JSON.stringify(data, null, 2);
            
            if (response.ok && data.success && data.data && data.data.accessToken) {
              jwtToken = data.data.accessToken;
              tokenDisplay.textContent = jwtToken;
              const roles = data.data.user?.roles || [];
              userBadge.style.display = 'inline-block';
              userBadge.textContent = '✅ Logged in as: ' + email + ' [' + roles.join(', ') + ']';
            } else {
              jwtToken = '';
              tokenDisplay.textContent = 'Failed to fetch token.';
              userBadge.style.display = 'none';
            }
          } catch (e) {
            statusBadge.style.display = 'block';
            statusBadge.className = 'status-badge status-error';
            statusBadge.textContent = 'NETWORK ERROR';
            output.textContent = 'Connection error: ' + e.message + '\n\nMake sure the server is running on port 5000.';
            userBadge.style.display = 'none';
          }
        }

        async function callApi(url, method) {
          const output = document.getElementById('response-output');
          const statusBadge = document.getElementById('status-badge');
          
          output.textContent = 'Calling API ' + url + '...';
          
          const headers = {
            'Content-Type': 'application/json'
          };
          
          if (jwtToken) {
            headers['Authorization'] = 'Bearer ' + jwtToken;
          }
          
          try {
            const response = await fetch(url, {
              method: method,
              headers: headers
            });
            
            const data = await response.json();
            
            statusBadge.style.display = 'block';
            statusBadge.className = response.ok ? 'status-badge status-success' : 'status-badge status-error';
            statusBadge.textContent = response.ok ? 'SUCCESS (' + response.status + ')' : 'ERROR (' + response.status + ')';
            
            output.textContent = JSON.stringify(data, null, 2);
          } catch (e) {
            statusBadge.style.display = 'block';
            statusBadge.className = 'status-badge status-error';
            statusBadge.textContent = 'NETWORK ERROR';
            output.textContent = e.message;
          }
        }
      </script>
    </body>
    </html>
  `);
});

/**
 * @swagger
 * tags:
 *   name: System
 *   description: System health and status endpoints
 */

/**
 * @swagger
 * /health:
 *   get:
 *     summary: System health check
 *     tags: [System]
 *     responses:
 *       200:
 *         description: System is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: ok
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *       503:
 *         description: Database unavailable
 */
// Health check
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
  } catch (e) {
    res.status(503).json({ status: 'error', message: 'Database unavailable' });
  }
});

// Swagger Documentation - serve at /api-docs
app.use(
  ['/api-docs', '/api/docs'],
  swaggerUi.serve,
  swaggerUi.setup(swaggerSpec, {
    customSiteTitle: 'PropAdmin API Docs',
    swaggerOptions: {
      persistAuthorization: true,          // keep JWT across page refreshes
      displayRequestDuration: true,
      filter: true,
      tryItOutEnabled: true,
      defaultModelsExpandDepth: 1,
      defaultModelExpandDepth: 2,
    },
    customCss: `
      .swagger-ui .topbar { background: #0f172a; }
      .swagger-ui .topbar .topbar-wrapper img { display: none; }
      .swagger-ui .topbar .topbar-wrapper::before {
        content: '🏠 PropAdmin API';
        color: #60a5fa;
        font-size: 1.2rem;
        font-weight: 700;
        letter-spacing: 0.05em;
      }
    `,
  })
);

// Raw OpenAPI spec as JSON (for import into Postman / Insomnia etc.)
app.get('/api-docs/swagger.json', (_req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// API Routes
app.get([`/api/${config.apiVersion}`, `/api/${config.apiVersion}/`], (req, res) => {
  res.json({
    success: true,
    message: "PropAdmin Backend API is running",
    version: config.apiVersion,
    consoleUrl: `${req.protocol}://${req.get('host')}/`,
    status: "online"
  });
});

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
app.use(`/api/${config.apiVersion}/ads`, adRouter);
app.use(`/api/${config.apiVersion}/screening`, screeningRouter);
app.use(`/api/${config.apiVersion}/move-in`, moveRouter);
app.use(`/api/${config.apiVersion}/move-out`, moveRouter);
app.use(`/api/${config.apiVersion}/payments`, lateRouter);
app.use(`/api/${config.apiVersion}/vendors`, vendorAdvancedRouter);
app.use(`/api/${config.apiVersion}/communications`, communicationRouter);
app.use(`/api/${config.apiVersion}/reports`, reportRouter);
app.use(`/api/${config.apiVersion}/marketing`, marketingRouter);
app.use(`/api/${config.apiVersion}/applications`, applicationRouter);
app.use(`/api/${config.apiVersion}/tenant`, tenantRouter);

// Error handling
app.use(errorHandler);

// WebSocket initialization
initializeSocketHandlers(io);

// Start server
async function bootstrap() {
  await initPostGIS();
  startCronJobs();
  httpServer.listen(config.port, () => {
    console.log(`🚀 PropAdmin API running on port ${config.port}`);
    console.log(`📡 WebSocket server active`);
    console.log(`🌍 Environment: ${config.nodeEnv}`);
    console.log(`📚 Available routes: ${Object.keys(app._router?.stack || {}).length} middlewares loaded`);
  });
}

bootstrap().catch(console.error);

export { app, io, httpServer };
