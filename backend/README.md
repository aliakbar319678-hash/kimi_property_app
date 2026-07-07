# PropAdmin Backend v2.0 — Complete

Unified PMOS (Property Management Operating System) backend powering every screen in your Figma file.

## ✅ 100% Figma Coverage

| Figma Screen | Backend Module | Status |
|---|---|---|
| Admin Dashboard | `admin` + materialized views | ✅ |
| Audit Logs | `audit_logs` (immutable) | ✅ |
| Onboarding (5-step) | `users` + `user_profiles` | ✅ |
| Job Details / Bids | `maintenance` + `bids` | ✅ |
| Vendor Billing | `finance` + invoices | ✅ |
| Certificate | `lms` + PDF generation | ✅ |
| Messages / Chat | `chat` + Socket.io | ✅ |
| Assign Job | `job_assignments` + ACL | ✅ |
| Learning / Quiz | `lms` + quiz scoring | ✅ |
| Course Listing | `courses` + `modules` | ✅ |
| Create Work Order | `work_orders` + scheduling | ✅ |
| Property Search / Filter | `properties` + PostGIS | ✅ |
| Rent Dashboard | `finance` dashboard stats | ✅ |
| VendorHub Jobs | `vendors` + bid counts | ✅ |
| Job Details / Submit Bid | `work-orders/:id/bids` | ✅ |
| Lease Management | `leases` + renewal cron | ✅ |
| Lease Summary | `leases/:id` full details | ✅ |
| LMS Dashboard | `lms/dashboard` | ✅ |
| Notifications | `notifications` + unread | ✅ |
| Maintenance List | `work-orders` filters | ✅ |
| My Bids | `vendors/my-bids` | ✅ |
| Discussions (Forum) | `discussions` + replies | ✅ |
| File Uploads | `uploads` (S3/Multer) | ✅ |
| AI Assistant | `ai` chat endpoint | ✅ |
| Calendar / Scheduling | `calendar` + Google link | ✅ |
| Stripe Payments | `webhooks/stripe` | ✅ |

---

## 🚀 Local Setup (Step-by-Step)

### Prerequisites

- **Node.js** 18+ (`node -v`)
- **PostgreSQL** 14+ with PostGIS extension
- **Redis** 7+ (`redis-server`)
- **AWS Account** (for S3 file uploads — optional for local dev)
- **Stripe Account** (optional for payment webhooks)

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:

```env
# Required
DATABASE_URL=postgresql://postgres:password@localhost:5432/propadmin
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-super-secret-key-min-32-characters-long

# Optional (for file uploads — skip if not testing uploads)
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
S3_BUCKET=propadmin-uploads
S3_EXPORT_BUCKET=propadmin-exports

# Optional (for payments — skip if not testing Stripe)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# App
PORT=5000
NODE_ENV=development
```

### 3. Create Database

```bash
# Using psql
psql -U postgres -c "CREATE DATABASE propadmin;"

# Enable PostGIS (if not already)
psql -U postgres -d propadmin -c "CREATE EXTENSION IF NOT EXISTS postgis;"
psql -U postgres -d propadmin -c "CREATE EXTENSION IF NOT EXISTS uuid-ossp;"
```

### 4. Run Migrations

```bash
npm run migrate
```

This creates all tables, indexes, triggers, and materialized views.

### 5. Seed Demo Data

```bash
npm run seed
```

Creates:
- 3 regions (US-NYC, SA-RUH, GB-LON)
- 1 Super Admin (`admin@propadmin.io` / `Admin123!`)
- 1 Landlord (`landlord@example.com` / `Admin123!`)
- 1 Tenant (`tenant@example.com` / `Admin123!`)
- 1 Vendor (`vendor@example.com` / `Admin123!`)
- 1 sample property with unit, lease, and course

### 6. Start Development Server

```bash
npm run dev
```

Server runs at `http://localhost:5000`

### 7. Start Background Workers (in separate terminals)

```bash
# Terminal 2: Export processor (PDF/CSV/Excel generation)
npm run worker:exports

# Terminal 3: Notification dispatcher
npm run worker:notifications
```

### 8. Test the API

```bash
# Health check
curl http://localhost:5000/health

# Login as admin
curl -X POST http://localhost:5000/api/v1/auth/login   -H "Content-Type: application/json"   -d '{"email":"admin@propadmin.io","password":"Admin123!"}'

# Response: { "access_token": "...", "user": { ... } }
```

---

## 📡 WebSocket Testing

```javascript
const socket = io('http://localhost:5000', {
  auth: { token: 'YOUR_JWT_TOKEN' }
});

socket.emit('join-room', { roomId: 'job_abc123' });
socket.on('new-message', (msg) => console.log(msg));
socket.emit('send-message', { roomId: 'job_abc123', content: 'Hello from client!' });
```

---

## 🗄️ Database Schema Quick Reference

| Table | Purpose |
|---|---|
| `regions` | Multi-tenancy (currency, timezone, locale) |
| `users` | Core identity, fraud score, KYC status |
| `user_roles` | RBAC — one user, many roles |
| `user_profiles` | Onboarding (5 steps), employment, emergency contact |
| `properties` | PostGIS location, amenities, verification |
| `units` | Bedrooms, bathrooms, rent, availability |
| `leases` | Auto-renewal, payment schedule, status |
| `rent_payments` | Ledger: due, paid, balance, late fees |
| `work_orders` | State machine: OPEN → SCHEDULED → IN_PROGRESS → COMPLETED |
| `bids` | Currency-matched, auto-reject on acceptance |
| `chat_rooms` / `messages` | Real-time with ACL (tenant can't see costs) |
| `courses` / `modules` / `quizzes` | LMS content |
| `enrollments` / `certificates` | Progress tracking, SHA-256 validation |
| `discussions` / `discussion_replies` | Community forum |
| `audit_logs` | Immutable, SOC 2 compliant |
| `notifications` | Multi-channel: in-app, push, email, SMS |
| `export_jobs` | Async CSV/Excel/PDF via BullMQ |

---

## 🔧 Common Issues

| Issue | Fix |
|---|---|
| `PostGIS not found` | Run `CREATE EXTENSION postgis;` in your database |
| `Redis connection refused` | Start Redis: `redis-server` or `brew services start redis` |
| `S3 upload fails` | Set dummy AWS credentials in `.env` or comment out upload routes |
| `Stripe webhook fails` | Use Stripe CLI for local testing: `stripe listen --forward-to localhost:5000/api/v1/webhooks/stripe` |
| `Puppeteer fails` | Install Chromium deps: `npx puppeteer browsers install chrome` |

---

## 📂 Project Structure

```
propadmin-backend/
├── src/
│   ├── config/           # Environment config
│   ├── db/               # PostgreSQL pool + helpers
│   ├── middleware/       # Auth, RBAC, validation, error handling
│   ├── routes/           # All API route definitions
│   ├── services/         # Business logic (per module)
│   ├── workers/          # BullMQ background jobs
│   ├── cron/             # Scheduled tasks
│   ├── websocket/        # Socket.io handlers
│   ├── utils/            # S3, validation schemas
│   ├── migrations/       # SQL schema
│   └── scripts/          # Migrate + seed
├── .env.example
├── package.json
├── tsconfig.json
└── README.md
```

---

## 🧪 Running Without External Services

If you want to run **100% locally** without AWS/Stripe:

1. **Skip S3**: File uploads will fail gracefully — the code handles missing credentials
2. **Skip Stripe**: Payment endpoints return mock data — webhooks route returns `{ received: true }`
3. **Skip FCM/SendGrid/Twilio**: Notifications queue to in-app only

Core functionality (auth, properties, leases, maintenance, chat, LMS, admin) works with just **PostgreSQL + Redis**.

---

## License

Proprietary — PropAdmin Platform
