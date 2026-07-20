import swaggerJsdoc from 'swagger-jsdoc';
import { config } from './index';
import path from 'path';
import fs from 'fs';

function resolveApiGlobs(): string[] {
  const srcRoutesTs = path.join(__dirname, '../routes/*.ts').replace(/\\/g, '/');
  const srcRoutesTsDir = path.join(__dirname, '../routes');
  const srcServerTs = path.join(__dirname, '../server.ts').replace(/\\/g, '/');
  const distRoutesJs = path.join(__dirname, '../routes/*.js').replace(/\\/g, '/');
  const distServerJs = path.join(__dirname, '../server.js').replace(/\\/g, '/');

  const hasTsRoutes =
    fs.existsSync(srcRoutesTsDir) &&
    fs.readdirSync(srcRoutesTsDir).some((f) => f.endsWith('.ts'));

  if (hasTsRoutes) {
    return [srcRoutesTs, srcServerTs];
  }
  return [distRoutesJs, distServerJs];
}

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'PropAdmin API Documentation',
      version: '2.0.0',
      description: `
## PropAdmin / T&L Property Management Platform API

Complete REST API covering **Auth, Properties, Leases, Finance, Maintenance, LMS, Chat, Notifications, Admin, Vendors, Uploads, Discussions, Calendar, AI & Webhooks** — 60+ endpoints.

### Authentication
All protected endpoints require a **Bearer JWT** token in the \`Authorization\` header.

**Quick Start:**
1. Call \`POST /api/v1/auth/login\` with email + password
2. Copy the \`accessToken\` from the response
3. Click **Authorize** (🔒) at the top right and paste the token

### Test Credentials
| Role | Email | Password |
|------|-------|----------|
| Super Admin | admin@propadmin.io | Admin123! |
| Landlord | landlord@example.com | Admin123! |
| Tenant | tenant@example.com | Admin123! |
| Vendor | vendor@example.com | Admin123! |

### Role-Based Access
| Role | Capabilities |
|------|-------------|
| \`super_admin\` | Full system access |
| \`admin\` | Dashboard, audit logs, verification |
| \`landlord\` | Properties, leases, maintenance, finance |
| \`tenant\` | Leases, payments, chat, LMS |
| \`vendor\` | Bids, jobs, earnings |
      `,
      contact: {
        name: 'PropAdmin Support',
        email: 'support@propadmin.io',
      },
    },
    servers: [
      {
        url: `http://localhost:${config.port}`,
        description: `Local Development Server (port ${config.port})`,
      },
      {
        url: `http://127.0.0.1:${config.port}`,
        description: 'Local Development Server (127.0.0.1)',
      },
    ],
    tags: [
      { name: 'System', description: 'Health check and system status' },
      { name: 'Auth', description: 'Register, login, token refresh, current user' },
      { name: 'Users', description: 'User profile, onboarding, documents, roles' },
      { name: 'Properties', description: 'Property CRUD, units, search, saved' },
      { name: 'Leases', description: 'Lease creation, dashboard, expiry tracking, renewal' },
      { name: 'Finance', description: 'Payments, vendor earnings, invoices, dashboard' },
      { name: 'Maintenance', description: 'Work orders, bids, vendor jobs' },
      { name: 'Chat', description: 'Chat rooms and messages' },
      { name: 'Notifications', description: 'User notifications and read status' },
      { name: 'Discussions', description: 'Community forum threads and replies' },
      { name: 'LMS', description: 'Learning courses, enrollments, quizzes, certificates' },
      { name: 'Vendors', description: 'Vendor bids, stats, and job assignments' },
      { name: 'Uploads', description: 'File uploads for properties, work orders, KYC' },
      { name: 'Calendar', description: 'Calendar events and Google Calendar integration' },
      { name: 'AI Assistant', description: 'AI-powered property management assistant' },
      { name: 'Admin', description: 'Admin dashboard, audit logs, user management' },
      { name: 'Webhooks', description: 'Stripe payment webhook handler' },
      { name: 'Ads', description: 'Advertisement and banner management' },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Paste your JWT access token (obtain from POST /api/v1/auth/login)',
        },
      },
      schemas: {
        // ─── Common ──────────────────────────────────────────────────────────
        SuccessResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string', example: 'Unauthorized' },
            statusCode: { type: 'integer', example: 401 },
          },
        },
        PaginationMeta: {
          type: 'object',
          properties: {
            page: { type: 'integer', example: 1 },
            limit: { type: 'integer', example: 20 },
            total: { type: 'integer', example: 100 },
          },
        },
        // ─── Auth ─────────────────────────────────────────────────────────────
        UserPublic: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '123e4567-e89b-12d3-a456-426614174000' },
            email: { type: 'string', example: 'user@example.com' },
            firstName: { type: 'string', example: 'John' },
            lastName: { type: 'string', example: 'Doe' },
            phoneNumber: { type: 'string', example: '+12125551234' },
            roles: { type: 'array', items: { type: 'string' }, example: ['tenant'] },
            activeRole: { type: 'string', example: 'tenant' },
            kycStatus: { type: 'string', example: 'pending' },
            onboardingStep: { type: 'integer', example: 3 },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        AuthTokens: {
          type: 'object',
          properties: {
            accessToken: { type: 'string', example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' },
            refreshToken: { type: 'string', example: 'def50200...' },
            user: { $ref: '#/components/schemas/UserPublic' },
          },
        },
        RegisterBody: {
          type: 'object',
          required: ['email', 'password', 'role'],
          properties: {
            email: { type: 'string', format: 'email', example: 'newuser@example.com' },
            password: { type: 'string', minLength: 8, example: 'StrongPass123!' },
            phone: { type: 'string', example: '+12125551234' },
            role: { type: 'string', enum: ['tenant', 'landlord', 'vendor'], example: 'tenant' },
            regionCode: { type: 'string', example: 'US' },
          },
        },
        LoginBody: {
          type: 'object',
          required: ['email', 'password'],
          properties: {
            email: { type: 'string', format: 'email', example: 'landlord@example.com' },
            password: { type: 'string', example: 'Admin123!' },
          },
        },
        // ─── Property ─────────────────────────────────────────────────────────
        Property: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            title: { type: 'string', example: 'Luxury Downtown Apartment' },
            description: { type: 'string' },
            address: { type: 'string', example: '123 Main St, New York, NY 10001' },
            type: { type: 'string', example: 'apartment' },
            price: { type: 'number', example: 2500 },
            bedrooms: { type: 'integer', example: 2 },
            bathrooms: { type: 'number', example: 1.5 },
            squareFeet: { type: 'number', example: 950 },
            landlordId: { type: 'string', format: 'uuid' },
            status: { type: 'string', enum: ['available', 'occupied', 'maintenance'], example: 'available' },
            images: { type: 'array', items: { type: 'string' } },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        PropertyCreate: {
          type: 'object',
          required: ['title', 'address', 'type'],
          properties: {
            title: { type: 'string', example: 'Luxury Apartment' },
            description: { type: 'string', example: 'Beautiful apartment in the city center' },
            address: { type: 'string', example: '123 Main St, New York, NY 10001' },
            type: { type: 'string', enum: ['apartment', 'house', 'condo', 'studio', 'commercial'], example: 'apartment' },
            price: { type: 'number', example: 2500 },
            bedrooms: { type: 'integer', example: 2 },
            bathrooms: { type: 'number', example: 1.5 },
            squareFeet: { type: 'number', example: 950 },
          },
        },
        Unit: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            propertyId: { type: 'string', format: 'uuid' },
            unitNumber: { type: 'string', example: 'Unit 3B' },
            price: { type: 'number', example: 1800 },
            status: { type: 'string', enum: ['vacant', 'occupied'], example: 'vacant' },
          },
        },
        // ─── Lease ────────────────────────────────────────────────────────────
        Lease: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            propertyId: { type: 'string', format: 'uuid' },
            unitId: { type: 'string', format: 'uuid' },
            tenantId: { type: 'string', format: 'uuid' },
            landlordId: { type: 'string', format: 'uuid' },
            startDate: { type: 'string', format: 'date', example: '2024-01-01' },
            endDate: { type: 'string', format: 'date', example: '2024-12-31' },
            rentAmount: { type: 'number', example: 2500 },
            securityDeposit: { type: 'number', example: 5000 },
            status: { type: 'string', enum: ['active', 'expired', 'terminated'], example: 'active' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        LeaseCreate: {
          type: 'object',
          required: ['propertyId', 'unitId', 'tenantId', 'startDate', 'endDate', 'rentAmount', 'securityDeposit'],
          properties: {
            propertyId: { type: 'string', format: 'uuid' },
            unitId: { type: 'string', format: 'uuid' },
            tenantId: { type: 'string', format: 'uuid' },
            startDate: { type: 'string', format: 'date', example: '2024-01-01' },
            endDate: { type: 'string', format: 'date', example: '2024-12-31' },
            rentAmount: { type: 'number', example: 2500 },
            securityDeposit: { type: 'number', example: 5000 },
          },
        },
        // ─── Finance ──────────────────────────────────────────────────────────
        Transaction: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            leaseId: { type: 'string', format: 'uuid' },
            amount: { type: 'number', example: 2500 },
            status: { type: 'string', enum: ['pending', 'completed', 'failed'], example: 'completed' },
            paymentMethod: { type: 'string', example: 'card' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        InvoiceItem: {
          type: 'object',
          required: ['description', 'amount'],
          properties: {
            description: { type: 'string', example: 'Labor - Plumbing repair' },
            amount: { type: 'number', example: 150 },
          },
        },
        // ─── Maintenance ──────────────────────────────────────────────────────
        WorkOrder: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            propertyId: { type: 'string', format: 'uuid' },
            unitId: { type: 'string', format: 'uuid' },
            title: { type: 'string', example: 'Broken pipe in bathroom' },
            description: { type: 'string' },
            category: { type: 'string', example: 'plumbing' },
            priority: { type: 'string', enum: ['low', 'medium', 'high', 'emergency'], example: 'high' },
            status: { type: 'string', enum: ['open', 'assigned', 'in_progress', 'completed', 'cancelled'], example: 'open' },
            assignedVendorId: { type: 'string', format: 'uuid', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        WorkOrderCreate: {
          type: 'object',
          required: ['propertyId', 'title', 'description', 'category', 'priority'],
          properties: {
            propertyId: { type: 'string', format: 'uuid' },
            unitId: { type: 'string', format: 'uuid' },
            title: { type: 'string', example: 'Broken pipe in bathroom' },
            description: { type: 'string', example: 'Water is leaking from under the sink' },
            category: { type: 'string', enum: ['plumbing', 'electrical', 'hvac', 'appliance', 'structural', 'other'], example: 'plumbing' },
            priority: { type: 'string', enum: ['low', 'medium', 'high', 'emergency'], example: 'high' },
          },
        },
        Bid: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            workOrderId: { type: 'string', format: 'uuid' },
            vendorId: { type: 'string', format: 'uuid' },
            amount: { type: 'number', example: 350 },
            estimatedDays: { type: 'integer', example: 2 },
            proposal: { type: 'string', example: 'I will fix the pipe and test for leaks' },
            status: { type: 'string', enum: ['pending', 'accepted', 'rejected'], example: 'pending' },
          },
        },
        BidCreate: {
          type: 'object',
          required: ['amount', 'estimatedDays', 'proposal'],
          properties: {
            amount: { type: 'number', example: 350 },
            estimatedDays: { type: 'integer', example: 2 },
            proposal: { type: 'string', example: 'I will fix the pipe and test for leaks' },
          },
        },
        // ─── Chat ─────────────────────────────────────────────────────────────
        ChatRoom: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            name: { type: 'string', example: 'Maintenance - Unit 3B' },
            contextType: { type: 'string', example: 'work_order' },
            contextId: { type: 'string', format: 'uuid' },
            participants: { type: 'array', items: { type: 'string', format: 'uuid' } },
            lastMessage: { type: 'string', example: 'I will arrive tomorrow at 9am' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        ChatMessage: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            roomId: { type: 'string', format: 'uuid' },
            senderId: { type: 'string', format: 'uuid' },
            content: { type: 'string', example: 'Hello, I will be there tomorrow.' },
            attachments: { type: 'array', items: { type: 'object' } },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── LMS ──────────────────────────────────────────────────────────────
        Course: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            title: { type: 'string', example: 'Property Management Fundamentals' },
            description: { type: 'string' },
            category: { type: 'string', example: 'fundamentals' },
            durationMinutes: { type: 'integer', example: 120 },
            modules: { type: 'array', items: { type: 'object' } },
          },
        },
        Certificate: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            certificateNumber: { type: 'string', example: 'CERT-2024-001234' },
            userId: { type: 'string', format: 'uuid' },
            courseId: { type: 'string', format: 'uuid' },
            issuedAt: { type: 'string', format: 'date-time' },
            status: { type: 'string', enum: ['active', 'revoked'], example: 'active' },
          },
        },
        // ─── Notification ─────────────────────────────────────────────────────
        Notification: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            type: { type: 'string', example: 'lease_expiring' },
            title: { type: 'string', example: 'Your lease expires in 30 days' },
            body: { type: 'string' },
            isRead: { type: 'boolean', example: false },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── Discussion ───────────────────────────────────────────────────────
        Discussion: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            title: { type: 'string', example: 'Tips for first-time landlords' },
            content: { type: 'string' },
            tags: { type: 'array', items: { type: 'string' }, example: ['landlord', 'tips'] },
            authorId: { type: 'string', format: 'uuid' },
            replyCount: { type: 'integer', example: 12 },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── LMS: Quiz ────────────────────────────────────────────────────────
        QuizQuestion: {
          type: 'object',
          properties: {
            id: { type: 'string', example: 'q1' },
            text: { type: 'string', example: 'What is the standard notice period for lease termination?' },
            options: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  id: { type: 'string', example: 'o1' },
                  text: { type: 'string', example: '30 days' },
                  is_correct: { type: 'boolean', example: true },
                },
              },
            },
          },
        },
        Quiz: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            moduleId: { type: 'string', format: 'uuid' },
            title: { type: 'string', example: 'Fair Housing Compliance Quiz' },
            questions: {
              type: 'array',
              items: { $ref: '#/components/schemas/QuizQuestion' },
            },
          },
        },
        QuizSubmitBody: {
          type: 'object',
          required: ['moduleId', 'answers'],
          properties: {
            moduleId: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            answers: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  questionId: { type: 'string', example: 'q1' },
                  selectedOptionId: { type: 'string', example: 'o2' },
                },
              },
            },
          },
        },
        QuizAttemptResult: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            enrollmentId: { type: 'string', format: 'uuid' },
            moduleId: { type: 'string', format: 'uuid' },
            scorePercent: { type: 'integer', example: 85 },
            passed: { type: 'boolean', example: true },
            answers: { type: 'array', items: { type: 'object' } },
            attemptedAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── LMS: Enrollment ──────────────────────────────────────────────────
        Enrollment: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            courseId: { type: 'string', format: 'uuid' },
            progressPercent: { type: 'integer', minimum: 0, maximum: 100, example: 65 },
            status: {
              type: 'string',
              enum: ['in_progress', 'completed', 'dropped'],
              example: 'in_progress',
            },
            startedAt: { type: 'string', format: 'date-time' },
            completedAt: { type: 'string', format: 'date-time', nullable: true },
            totalTimeSpent: { type: 'integer', description: 'Total minutes spent on course', example: 90 },
          },
        },
        EnrollmentProgressBody: {
          type: 'object',
          required: ['progressPercent'],
          properties: {
            progressPercent: { type: 'integer', minimum: 0, maximum: 100, example: 75 },
          },
        },
        // ─── Discussion: DiscussionReply ───────────────────────────────────────
        DiscussionReply: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            discussionId: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            parentId: { type: 'string', format: 'uuid', nullable: true, description: 'Parent reply ID for nested replies' },
            content: { type: 'string', example: 'Great point! This helped me a lot.' },
            upvotes: { type: 'integer', example: 5 },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        DiscussionReplyBody: {
          type: 'object',
          required: ['content'],
          properties: {
            content: { type: 'string', example: 'Thanks for sharing this insight!' },
            parentId: { type: 'string', format: 'uuid', nullable: true },
          },
        },
        // ─── Calendar: CalendarEvent ───────────────────────────────────────────
        CalendarEventBody: {
          type: 'object',
          required: ['title', 'startDate', 'endDate'],
          properties: {
            title: { type: 'string', example: 'Lease Renewal Meeting' },
            description: { type: 'string', example: 'Discussing renewal terms with tenant John Smith' },
            startDate: { type: 'string', format: 'date-time', example: '2024-06-15T10:00:00Z' },
            endDate: { type: 'string', format: 'date-time', example: '2024-06-15T11:00:00Z' },
            location: { type: 'string', example: '123 Broadway, New York, NY' },
            attendees: { type: 'array', items: { type: 'string', format: 'email' }, example: ['tenant@example.com'] },
          },
        },
        CalendarEvent: {
          type: 'object',
          properties: {
            eventId: { type: 'string', example: 'evt_1717423200000' },
            status: { type: 'string', example: 'confirmed' },
            htmlLink: { type: 'string', format: 'uri', example: 'https://calendar.google.com/calendar/event?eid=placeholder' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        GoogleCalendarLinkBody: {
          type: 'object',
          required: ['title', 'startDate', 'endDate'],
          properties: {
            title: { type: 'string', example: 'Property Inspection' },
            startDate: { type: 'string', example: '20240615T100000Z' },
            endDate: { type: 'string', example: '20240615T110000Z' },
            location: { type: 'string', example: '123 Broadway, New York' },
          },
        },
        // ─── Vendor Schemas ────────────────────────────────────────────────────
        VendorBid: {
          type: 'object',
          description: 'A bid submitted by this vendor, with enriched work order context',
          properties: {
            id: { type: 'string', format: 'uuid' },
            workOrderId: { type: 'string', format: 'uuid' },
            workOrderTitle: { type: 'string', example: 'Leaking kitchen faucet' },
            category: { type: 'string', example: 'plumbing' },
            priority: { type: 'string', enum: ['low', 'medium', 'high', 'emergency'], example: 'medium' },
            workOrderStatus: { type: 'string', example: 'open' },
            propertyName: { type: 'string', example: 'Sunset Heights Apts' },
            unitNumber: { type: 'string', example: '402' },
            amount: { type: 'number', example: 120.00 },
            currency: { type: 'string', example: 'USD' },
            message: { type: 'string', example: 'Can fix it tomorrow morning.' },
            estimatedHours: { type: 'integer', example: 2 },
            proposedDate: { type: 'string', format: 'date-time' },
            status: { type: 'string', enum: ['pending', 'accepted', 'rejected', 'withdrawn'], example: 'pending' },
            isFixedPrice: { type: 'boolean', example: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        VendorStats: {
          type: 'object',
          properties: {
            totalBids: { type: 'integer', example: 15 },
            acceptedBids: { type: 'integer', example: 9 },
            totalEarnings: { type: 'number', example: 4250.00, description: 'Total earnings from completed job assignments' },
            averageRating: { type: 'number', format: 'float', example: 4.7, description: 'Average star rating from landlord reviews (1-5)' },
          },
        },
        VendorJob: {
          type: 'object',
          description: 'A work order assigned to this vendor',
          properties: {
            id: { type: 'string', format: 'uuid' },
            propertyId: { type: 'string', format: 'uuid' },
            unitId: { type: 'string', format: 'uuid' },
            propertyName: { type: 'string', example: 'Sunset Heights Apts' },
            unitNumber: { type: 'string', example: '402' },
            title: { type: 'string', example: 'Leaking kitchen faucet' },
            description: { type: 'string' },
            category: { type: 'string', example: 'plumbing' },
            priority: { type: 'string', enum: ['low', 'medium', 'high', 'emergency'], example: 'medium' },
            status: {
              type: 'string',
              enum: ['open', 'scheduled', 'in_progress', 'waiting_parts', 'completed', 'cancelled'],
              example: 'scheduled',
            },
            scheduledDate: { type: 'string', format: 'date-time', nullable: true },
            completedDate: { type: 'string', format: 'date-time', nullable: true },
            budgetMin: { type: 'number', example: 50.00 },
            budgetMax: { type: 'number', example: 200.00 },
            currency: { type: 'string', example: 'USD' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── KYC / Uploads ────────────────────────────────────────────────────
        KYCDocument: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            docType: {
              type: 'string',
              enum: ['passport', 'id_card', 'drivers_license', 'proof_of_income', 'bank_statement', 'utility_bill'],
              example: 'passport',
            },
            fileUrl: { type: 'string', format: 'uri', example: 'https://s3.amazonaws.com/propadmin-uploads/kyc/user-id/doc.pdf' },
            verificationStatus: {
              type: 'string',
              enum: ['pending', 'approved', 'rejected'],
              example: 'pending',
            },
            reviewedBy: { type: 'string', format: 'uuid', nullable: true },
            reviewedAt: { type: 'string', format: 'date-time', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        UploadResult: {
          type: 'object',
          properties: {
            key: { type: 'string', example: 'uploads/kyc/user-id/550e8400-e29b-41d4-a716-446655440000.pdf' },
            url: { type: 'string', format: 'uri', example: 'https://s3.amazonaws.com/propadmin-uploads/uploads/kyc/...' },
            expiresIn: { type: 'integer', example: 604800, description: 'Signed URL expiry in seconds (7 days)' },
          },
        },
        AvatarUploadResult: {
          type: 'object',
          description: 'Result returned after a successful avatar upload',
          properties: {
            key: { type: 'string', example: 'avatars/user-uuid/550e8400.png', description: 'S3 object key' },
            url: {
              type: 'string',
              format: 'uri',
              example: 'https://s3.amazonaws.com/propadmin-uploads/avatars/user-uuid/photo.png?X-Amz-Signature=...',
              description: 'Pre-signed S3 URL valid for 1 year',
            },
            expiresIn: { type: 'integer', example: 31536000, description: 'Signed URL validity in seconds (1 year = 31 536 000)' },
          },
        },
        // ─── AI Assistant ─────────────────────────────────────────────────────
        AIChatBody: {
          type: 'object',
          required: ['message'],
          properties: {
            message: { type: 'string', example: 'Which leases are expiring this month?' },
            propertyId: { type: 'string', format: 'uuid', nullable: true },
            leaseId: { type: 'string', format: 'uuid', nullable: true },
          },
        },
        AISuggestedAction: {
          type: 'object',
          properties: {
            label: { type: 'string', example: 'Show expiring leases' },
            action: { type: 'string', enum: ['navigate', 'download', 'api'], example: 'navigate' },
            url: { type: 'string', example: '/leases/expiring' },
            method: { type: 'string', enum: ['GET', 'POST', 'PUT', 'DELETE'], nullable: true },
          },
        },
        AIChatMessage: {
          type: 'object',
          properties: {
            response: {
              type: 'string',
              example: "You have 3 leases expiring within 30 days. Would you like me to generate renewal offers?",
            },
            suggestedActions: {
              type: 'array',
              items: { $ref: '#/components/schemas/AISuggestedAction' },
            },
            source: {
              type: 'string',
              enum: ['system_analysis', 'openai', 'default'],
              example: 'system_analysis',
            },
          },
        },
        // ─── Admin: AuditLog ──────────────────────────────────────────────────
        AuditLog: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid', nullable: true },
            userEmail: { type: 'string', format: 'email', example: 'admin@propadmin.io' },
            userName: { type: 'string', example: 'Alex Thompson' },
            userRole: { type: 'string', example: 'super_admin' },
            action: { type: 'string', example: 'SUSPENDED', description: 'Action performed (e.g. FILE_UPLOADED, SUSPENDED, LOGIN)' },
            entityType: { type: 'string', example: 'user', nullable: true },
            entityId: { type: 'string', format: 'uuid', nullable: true },
            details: { type: 'object', additionalProperties: true, example: { reason: 'Fraudulent activity detected' } },
            ipAddress: { type: 'string', example: '192.168.1.100', nullable: true },
            userAgent: { type: 'string', example: 'Mozilla/5.0 ...', nullable: true },
            sessionId: { type: 'string', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── Admin: VerificationRequest ────────────────────────────────────────
        VerificationRequest: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            email: { type: 'string', format: 'email', example: 'tenant@example.com' },
            displayName: { type: 'string', example: 'John Smith' },
            fraudScore: { type: 'integer', minimum: 0, maximum: 100, example: 0 },
            caseType: {
              type: 'string',
              enum: ['identity', 'income', 'employment', 'fraud_review'],
              example: 'identity',
            },
            status: {
              type: 'string',
              enum: ['pending_review', 'approved', 'rejected', 'escalated'],
              example: 'pending_review',
            },
            assignedAdminId: { type: 'string', format: 'uuid', nullable: true },
            riskFlags: {
              type: 'array',
              items: { type: 'object' },
              example: [{ note: 'Mismatched address', reviewed_by: 'admin-id', at: '2024-06-10T00:00:00Z' }],
            },
            reviewedAt: { type: 'string', format: 'date-time', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // ─── System: SystemHealth ─────────────────────────────────────────────
        SystemHealthMetric: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            metricName: { type: 'string', example: 'db_connection_pool' },
            metricValue: { type: 'string', example: '18/20' },
            status: {
              type: 'string',
              enum: ['clean', 'warning', 'critical'],
              example: 'clean',
            },
            regionId: { type: 'string', format: 'uuid', nullable: true },
            checkedAt: { type: 'string', format: 'date-time' },
          },
        },
        SystemHealth: {
          type: 'object',
          description: 'Aggregated system health summary',
          properties: {
            status: { type: 'string', format: 'date-time' },
            timestamp: { type: 'string', format: 'date-time' },
            metrics: {
              type: 'array',
              items: { $ref: '#/components/schemas/SystemHealthMetric' },
            },
          },
        },
      },
      responses: {
        Unauthorized: {
          description: 'Missing or invalid authentication token',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Unauthorized', statusCode: 401 },
            },
          },
        },
        Forbidden: {
          description: 'Insufficient role/permissions',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Forbidden: insufficient role', statusCode: 403 },
            },
          },
        },
        NotFound: {
          description: 'Resource not found',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: 'Not found', statusCode: 404 },
            },
          },
        },
        ValidationError: {
          description: 'Request body validation failed',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ErrorResponse' },
              example: { success: false, message: '"email" must be a valid email', statusCode: 400 },
            },
          },
        },
      },
    },
    security: [{ bearerAuth: [] }],
    paths: {
      // ═══════════════════════════════════════════════════════════════════════
      // SYSTEM
      // ═══════════════════════════════════════════════════════════════════════
      '/health': {
        get: {
          tags: ['System'],
          summary: 'Health check',
          description: 'Returns 200 if the server and database are reachable.',
          operationId: 'healthCheck',
          security: [],
          responses: {
            200: {
              description: 'Server is healthy',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      status: { type: 'string', example: 'ok' },
                      timestamp: { type: 'string', format: 'date-time' },
                    },
                  },
                },
              },
            },
            503: { description: 'Database unavailable' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // AUTH
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/auth/register': {
        post: {
          tags: ['Auth'],
          summary: 'Register a new user',
          description: 'Creates a new user account. Role must be one of: tenant, landlord, vendor.',
          operationId: 'authRegister',
          security: [],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/RegisterBody' },
              },
            },
          },
          responses: {
            201: {
              description: 'User registered successfully',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/UserPublic' },
                    },
                  },
                },
              },
            },
            400: { $ref: '#/components/responses/ValidationError' },
          },
        },
      },
      '/api/v1/auth/login': {
        post: {
          tags: ['Auth'],
          summary: 'Login and get JWT tokens',
          description: 'Authenticates the user and returns an accessToken (short-lived) and refreshToken (long-lived).',
          operationId: 'authLogin',
          security: [],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/LoginBody' },
                examples: {
                  superAdmin: { summary: 'Super Admin', value: { email: 'admin@propadmin.io', password: 'Admin123!' } },
                  landlord: { summary: 'Landlord', value: { email: 'landlord@example.com', password: 'Admin123!' } },
                  tenant: { summary: 'Tenant', value: { email: 'tenant@example.com', password: 'Admin123!' } },
                  vendor: { summary: 'Vendor', value: { email: 'vendor@example.com', password: 'Admin123!' } },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Login successful',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/AuthTokens' },
                    },
                  },
                },
              },
            },
            400: { $ref: '#/components/responses/ValidationError' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/auth/refresh': {
        post: {
          tags: ['Auth'],
          summary: 'Refresh access token',
          description: 'Exchange a valid refresh token for a new access token + refresh token pair.',
          operationId: 'authRefresh',
          security: [],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['refreshToken'],
                  properties: {
                    refreshToken: { type: 'string', example: 'def50200...' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'New token pair returned',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/AuthTokens' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/auth/me': {
        get: {
          tags: ['Auth'],
          summary: 'Get current authenticated user',
          description: 'Returns the full profile of the currently logged-in user based on the JWT.',
          operationId: 'authMe',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Current user profile',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/UserPublic' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // USERS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/users/me/profile': {
        put: {
          tags: ['Users'],
          summary: 'Update current user profile',
          description: 'Update firstName, lastName, or phoneNumber for the authenticated user.',
          operationId: 'updateProfile',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    firstName: { type: 'string', example: 'John' },
                    lastName: { type: 'string', example: 'Doe' },
                    phoneNumber: { type: 'string', example: '+12125551234' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Profile updated',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/UserPublic' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/users/me/onboarding/{step}': {
        post: {
          tags: ['Users'],
          summary: 'Complete onboarding step',
          description: 'Saves data for a specific onboarding step (1–5). Each step progressively builds the user profile.',
          operationId: 'completeOnboardingStep',
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              in: 'path',
              name: 'step',
              required: true,
              schema: { type: 'integer', minimum: 1, maximum: 5 },
              description: 'Onboarding step number (1–5)',
            },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'object',
                      example: { firstName: 'John', lastName: 'Doe', dateOfBirth: '1990-01-15' },
                    },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Step saved successfully' },
            401: { $ref: '#/components/responses/Unauthorized' },
            400: { $ref: '#/components/responses/ValidationError' },
          },
        },
      },
      '/api/v1/users/me/documents': {
        post: {
          tags: ['Users'],
          summary: 'Record uploaded document reference',
          description: 'Saves a document record (docType + fileUrl) after the file has been uploaded via the /uploads/kyc endpoint.',
          operationId: 'uploadUserDocument',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['docType', 'fileUrl'],
                  properties: {
                    docType: { type: 'string', enum: ['passport', 'drivers_license', 'national_id', 'utility_bill'], example: 'passport' },
                    fileUrl: { type: 'string', format: 'uri', example: 'https://s3.amazonaws.com/bucket/doc.pdf' },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Document recorded' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/users/{id}/roles': {
        get: {
          tags: ['Users'],
          summary: 'Get roles for a user (Admin only)',
          operationId: 'getUserRoles',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'User UUID' },
          ],
          responses: {
            200: {
              description: 'List of user roles',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { type: 'string' }, example: ['tenant', 'landlord'] },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
        post: {
          tags: ['Users'],
          summary: 'Add a role to a user (Super Admin only)',
          operationId: 'addUserRole',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'User UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['role'],
                  properties: {
                    role: { type: 'string', enum: ['tenant', 'landlord', 'vendor', 'admin', 'super_admin'], example: 'landlord' },
                    entityId: { type: 'string', format: 'uuid', description: 'Associated entity ID (e.g. property)' },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Role added' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // PROPERTIES
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/properties': {
        post: {
          tags: ['Properties'],
          summary: 'Create a new property',
          description: 'Creates a property listing. Requires landlord, property_manager, or admin role.',
          operationId: 'createProperty',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/PropertyCreate' },
              },
            },
          },
          responses: {
            201: {
              description: 'Property created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Property' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/properties/search': {
        get: {
          tags: ['Properties'],
          summary: 'Search properties (Public)',
          description: 'Full-text + filter search over property listings. No authentication required.',
          operationId: 'searchProperties',
          security: [],
          parameters: [
            { in: 'query', name: 'q', schema: { type: 'string' }, description: 'Keyword search', example: 'downtown apartment' },
            { in: 'query', name: 'type', schema: { type: 'string', enum: ['apartment', 'house', 'condo', 'studio', 'commercial'] }, description: 'Property type' },
            { in: 'query', name: 'minPrice', schema: { type: 'number' }, description: 'Minimum monthly rent', example: 1000 },
            { in: 'query', name: 'maxPrice', schema: { type: 'number' }, description: 'Maximum monthly rent', example: 5000 },
            { in: 'query', name: 'bedrooms', schema: { type: 'integer' }, description: 'Number of bedrooms' },
            { in: 'query', name: 'city', schema: { type: 'string' }, description: 'City name' },
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
          ],
          responses: {
            200: {
              description: 'Search results',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Property' } },
                      total: { type: 'integer', example: 42 },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/api/v1/properties/saved/me': {
        get: {
          tags: ['Properties'],
          summary: "Get tenant's saved properties",
          description: 'Returns all properties the authenticated tenant has bookmarked/saved.',
          operationId: 'getSavedProperties',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Saved properties list',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Property' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/properties/{id}': {
        get: {
          tags: ['Properties'],
          summary: 'Get property by ID',
          operationId: 'getPropertyById',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Property UUID' },
          ],
          responses: {
            200: {
              description: 'Property details',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Property' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            404: { $ref: '#/components/responses/NotFound' },
          },
        },
      },
      '/api/v1/properties/{id}/units': {
        post: {
          tags: ['Properties'],
          summary: 'Add unit to a property',
          description: 'Creates a rentable unit within a property. Requires landlord or property_manager role.',
          operationId: 'createPropertyUnit',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Property UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['unitNumber', 'price'],
                  properties: {
                    unitNumber: { type: 'string', example: 'Unit 3B' },
                    price: { type: 'number', example: 1800 },
                    bedrooms: { type: 'integer', example: 2 },
                    bathrooms: { type: 'number', example: 1 },
                    squareFeet: { type: 'number', example: 750 },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description: 'Unit created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Unit' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/properties/{id}/save': {
        post: {
          tags: ['Properties'],
          summary: 'Bookmark/save a property (Tenant)',
          operationId: 'saveProperty',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Property UUID' },
          ],
          responses: {
            200: { description: 'Property saved to bookmarks' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // LEASES
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/leases': {
        post: {
          tags: ['Leases'],
          summary: 'Create a new lease',
          description: 'Creates a lease contract between a landlord and tenant for a specific property unit.',
          operationId: 'createLease',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/LeaseCreate' },
              },
            },
          },
          responses: {
            201: {
              description: 'Lease created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Lease' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/leases/dashboard': {
        get: {
          tags: ['Leases'],
          summary: 'Lease dashboard (role-aware)',
          description: 'Returns active leases and statistics. Landlords see all their leases; tenants see their own.',
          operationId: 'getLeaseDashboard',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Lease dashboard data',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Lease' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/leases/expiring-soon': {
        get: {
          tags: ['Leases'],
          summary: 'Get leases expiring in the next 30/60 days (Landlord)',
          operationId: 'getExpiringSoonLeases',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Expiring leases',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Lease' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/leases/{id}/renew': {
        post: {
          tags: ['Leases'],
          summary: 'Renew a lease (Landlord)',
          description: 'Extends the lease end date and creates a new lease record.',
          operationId: 'renewLease',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Lease UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['newEndDate'],
                  properties: {
                    newEndDate: { type: 'string', format: 'date', example: '2025-12-31' },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Lease renewed' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // FINANCE
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/finance/dashboard': {
        get: {
          tags: ['Finance'],
          summary: 'Finance dashboard (role-aware)',
          description: 'Returns financial statistics. Period can be daily/weekly/monthly/yearly.',
          operationId: 'getFinanceDashboard',
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              in: 'query',
              name: 'period',
              schema: { type: 'string', enum: ['daily', 'weekly', 'monthly', 'yearly'], default: 'monthly' },
              description: 'Time period for aggregation',
            },
          ],
          responses: {
            200: {
              description: 'Finance statistics',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: {
                        type: 'object',
                        properties: {
                          totalRevenue: { type: 'number', example: 50000 },
                          totalExpenses: { type: 'number', example: 12000 },
                          netIncome: { type: 'number', example: 38000 },
                          pendingPayments: { type: 'number', example: 5000 },
                          recentTransactions: { type: 'array', items: { $ref: '#/components/schemas/Transaction' } },
                        },
                      },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/finance/payments/initiate': {
        post: {
          tags: ['Finance'],
          summary: 'Initiate a rent payment via Stripe (Tenant)',
          description: 'Creates a Stripe PaymentIntent and returns the clientSecret for front-end confirmation.',
          operationId: 'initiatePayment',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['leaseId', 'amount', 'paymentMethod'],
                  properties: {
                    leaseId: { type: 'string', format: 'uuid' },
                    amount: { type: 'number', example: 2500 },
                    paymentMethod: { type: 'string', enum: ['card', 'bank_transfer', 'ach'], example: 'card' },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description: 'Payment intent created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: {
                        type: 'object',
                        properties: {
                          paymentIntentId: { type: 'string', example: 'pi_3NxKqP2eZvKYlo2C0xyz' },
                          clientSecret: { type: 'string', example: 'pi_3Nx...secret' },
                          amount: { type: 'number', example: 2500 },
                        },
                      },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/finance/vendor/earnings': {
        get: {
          tags: ['Finance'],
          summary: 'Get vendor earnings (Vendor only)',
          description: 'Returns total earnings, pending payments, and transaction history for the authenticated vendor.',
          operationId: 'getVendorEarnings',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Vendor earnings',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: {
                        type: 'object',
                        properties: {
                          totalEarnings: { type: 'number', example: 8500 },
                          pendingPayments: { type: 'number', example: 1200 },
                          history: { type: 'array', items: { $ref: '#/components/schemas/Transaction' } },
                        },
                      },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/finance/invoices': {
        post: {
          tags: ['Finance'],
          summary: 'Generate vendor invoice for a work order (Vendor)',
          operationId: 'generateInvoice',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['workOrderId', 'items'],
                  properties: {
                    workOrderId: { type: 'string', format: 'uuid' },
                    items: {
                      type: 'array',
                      items: { $ref: '#/components/schemas/InvoiceItem' },
                      example: [
                        { description: 'Labor - Plumbing repair', amount: 150 },
                        { description: 'Parts - Copper pipe fittings', amount: 45 },
                      ],
                    },
                  },
                },
              },
            },
          },
          responses: {
            201: { description: 'Invoice generated' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // MAINTENANCE
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/maintenance/work-orders': {
        post: {
          tags: ['Maintenance'],
          summary: 'Create a work order (Landlord)',
          operationId: 'createWorkOrder',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/WorkOrderCreate' },
              },
            },
          },
          responses: {
            201: {
              description: 'Work order created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/WorkOrder' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
        get: {
          tags: ['Maintenance'],
          summary: 'Get work orders (role-filtered)',
          description: 'Returns work orders. Landlords see their own; vendors see work orders open for bidding.',
          operationId: 'getWorkOrders',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['open', 'assigned', 'in_progress', 'completed', 'cancelled'] } },
            { in: 'query', name: 'category', schema: { type: 'string' } },
            { in: 'query', name: 'priority', schema: { type: 'string', enum: ['low', 'medium', 'high', 'emergency'] } },
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
          ],
          responses: {
            200: {
              description: 'List of work orders',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/WorkOrder' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/maintenance/work-orders/{id}': {
        get: {
          tags: ['Maintenance'],
          summary: 'Get work order by ID',
          operationId: 'getWorkOrderById',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Work Order UUID' },
          ],
          responses: {
            200: {
              description: 'Work order details',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/WorkOrder' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            404: { $ref: '#/components/responses/NotFound' },
          },
        },
      },
      '/api/v1/maintenance/work-orders/{id}/bids': {
        post: {
          tags: ['Maintenance'],
          summary: 'Submit a bid on a work order (Vendor)',
          operationId: 'submitBid',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Work Order UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/BidCreate' },
              },
            },
          },
          responses: {
            201: {
              description: 'Bid submitted',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Bid' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/maintenance/work-orders/{id}/status': {
        put: {
          tags: ['Maintenance'],
          summary: 'Update work order status',
          description: 'Landlords can move to any status; vendors can only mark as in_progress or completed.',
          operationId: 'updateWorkOrderStatus',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Work Order UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['status'],
                  properties: {
                    status: { type: 'string', enum: ['open', 'assigned', 'in_progress', 'completed', 'cancelled'] },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Status updated' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/maintenance/bids/{id}/accept': {
        post: {
          tags: ['Maintenance'],
          summary: 'Accept a vendor bid (Landlord)',
          description: 'Accepts the bid, rejects all other bids for that work order, and assigns the vendor.',
          operationId: 'acceptBid',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Bid UUID' },
          ],
          responses: {
            200: { description: 'Bid accepted and vendor assigned' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/maintenance/vendor/jobs': {
        get: {
          tags: ['Maintenance'],
          summary: 'Get jobs assigned to vendor (Vendor)',
          operationId: 'getVendorJobs',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['assigned', 'in_progress', 'completed'] } },
          ],
          responses: {
            200: {
              description: 'Vendor jobs list',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/WorkOrder' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // CHAT
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/chat/rooms': {
        post: {
          tags: ['Chat'],
          summary: 'Create a chat room',
          operationId: 'createChatRoom',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['name', 'participants', 'contextType', 'contextId'],
                  properties: {
                    name: { type: 'string', example: 'Maintenance - Unit 3B' },
                    participants: { type: 'array', items: { type: 'string', format: 'uuid' }, example: ['uuid1', 'uuid2'] },
                    contextType: { type: 'string', enum: ['work_order', 'lease', 'property', 'general'], example: 'work_order' },
                    contextId: { type: 'string', format: 'uuid' },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description: 'Chat room created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/ChatRoom' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
        get: {
          tags: ['Chat'],
          summary: 'Get all chat rooms for current user',
          operationId: 'getChatRooms',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'List of chat rooms',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/ChatRoom' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/chat/rooms/{id}/messages': {
        get: {
          tags: ['Chat'],
          summary: 'Get messages in a chat room (paginated)',
          operationId: 'getChatMessages',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Chat Room UUID' },
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 50 } },
          ],
          responses: {
            200: {
              description: 'Messages',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/ChatMessage' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
        post: {
          tags: ['Chat'],
          summary: 'Send a message in a chat room',
          operationId: 'sendChatMessage',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Chat Room UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['content'],
                  properties: {
                    content: { type: 'string', example: 'I will be there tomorrow at 9am.' },
                    attachments: { type: 'array', items: { type: 'object' } },
                  },
                },
              },
            },
          },
          responses: {
            201: { description: 'Message sent' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/chat/rooms/{id}/read': {
        put: {
          tags: ['Chat'],
          summary: 'Mark all messages in a room as read',
          operationId: 'markChatRead',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Chat Room UUID' },
          ],
          responses: {
            200: { description: 'Messages marked as read' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // NOTIFICATIONS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/notifications': {
        get: {
          tags: ['Notifications'],
          summary: 'Get all notifications (paginated)',
          operationId: 'getNotifications',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
          ],
          responses: {
            200: {
              description: 'Notifications list',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Notification' } },
                      total: { type: 'integer', example: 25 },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/notifications/unread': {
        get: {
          tags: ['Notifications'],
          summary: 'Get unread notifications',
          operationId: 'getUnreadNotifications',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Unread notifications',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Notification' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/notifications/unread-count': {
        get: {
          tags: ['Notifications'],
          summary: 'Get unread notification count',
          operationId: 'getUnreadCount',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Unread count',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'object', properties: { count: { type: 'integer', example: 5 } } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/notifications/read-all': {
        put: {
          tags: ['Notifications'],
          summary: 'Mark all notifications as read',
          operationId: 'markAllNotificationsRead',
          security: [{ bearerAuth: [] }],
          responses: {
            200: { description: 'All notifications marked as read' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/notifications/{id}/read': {
        put: {
          tags: ['Notifications'],
          summary: 'Mark a single notification as read',
          operationId: 'markNotificationRead',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Notification UUID' },
          ],
          responses: {
            200: { description: 'Notification marked as read' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // DISCUSSIONS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/discussions': {
        post: {
          tags: ['Discussions'],
          summary: 'Create a new discussion thread',
          operationId: 'createDiscussion',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['title', 'content', 'tags'],
                  properties: {
                    title: { type: 'string', example: 'Best practices for lease renewals?' },
                    content: { type: 'string', example: 'I wanted to get the communities thoughts on...' },
                    tags: { type: 'array', items: { type: 'string' }, example: ['leases', 'tips'] },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description: 'Discussion created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Discussion' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
        get: {
          tags: ['Discussions'],
          summary: 'List all discussions',
          operationId: 'listDiscussions',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'tags', schema: { type: 'string' }, description: 'Comma-separated tag filters' },
            { in: 'query', name: 'sortBy', schema: { type: 'string', enum: ['recent', 'popular'], default: 'recent' } },
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
          ],
          responses: {
            200: {
              description: 'List of discussions',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Discussion' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/discussions/{id}': {
        get: {
          tags: ['Discussions'],
          summary: 'Get discussion by ID (with replies)',
          operationId: 'getDiscussionById',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Discussion UUID' },
          ],
          responses: {
            200: { description: 'Discussion with replies' },
            401: { $ref: '#/components/responses/Unauthorized' },
            404: { $ref: '#/components/responses/NotFound' },
          },
        },
      },
      '/api/v1/discussions/{id}/replies': {
        post: {
          tags: ['Discussions'],
          summary: 'Post a reply to a discussion',
          operationId: 'replyToDiscussion',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Discussion UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['content'],
                  properties: {
                    content: { type: 'string', example: 'Great point! I usually give 90 days notice...' },
                    parentId: { type: 'string', format: 'uuid', description: 'For nested replies' },
                  },
                },
              },
            },
          },
          responses: {
            201: { description: 'Reply posted' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/discussions/replies/{id}/upvote': {
        post: {
          tags: ['Discussions'],
          summary: 'Upvote a discussion reply',
          operationId: 'upvoteReply',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Reply UUID' },
          ],
          responses: {
            200: { description: 'Reply upvoted' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // LMS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/lms/courses': {
        get: {
          tags: ['LMS'],
          summary: 'Get all available courses',
          operationId: 'getCourses',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'category', schema: { type: 'string' }, description: 'Filter by category' },
          ],
          responses: {
            200: {
              description: 'List of courses',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Course' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/courses/{id}': {
        get: {
          tags: ['LMS'],
          summary: 'Get course details by ID',
          operationId: 'getCourseById',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Course UUID' },
          ],
          responses: {
            200: { description: 'Course details with modules' },
            404: { $ref: '#/components/responses/NotFound' },
          },
        },
      },
      '/api/v1/lms/courses/{id}/enroll': {
        post: {
          tags: ['LMS'],
          summary: 'Enroll in a course',
          operationId: 'enrollCourse',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Course UUID' },
          ],
          responses: {
            201: {
              description: 'Enrollment created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Enrollment' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/enrollments/{id}/progress': {
        put: {
          tags: ['LMS'],
          summary: 'Update course progress percentage',
          operationId: 'updateCourseProgress',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Enrollment UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/EnrollmentProgressBody' },
              },
            },
          },
          responses: {
            200: {
              description: 'Progress updated',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Enrollment' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/modules/{id}/quiz': {
        get: {
          tags: ['LMS'],
          summary: 'Get quiz for a module',
          operationId: 'getModuleQuiz',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Module UUID' },
          ],
          responses: {
            200: {
              description: 'Quiz questions',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Quiz' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/enrollments/{id}/quiz': {
        post: {
          tags: ['LMS'],
          summary: 'Submit quiz answers',
          operationId: 'submitQuiz',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Enrollment UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/QuizSubmitBody' },
              },
            },
          },
          responses: {
            200: {
              description: 'Quiz graded',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/QuizAttemptResult' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/certificates': {
        get: {
          tags: ['LMS'],
          summary: 'Get all certificates for current user',
          operationId: 'getCertificates',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'User certificates',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/Certificate' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/enrollments/{id}/certificate': {
        post: {
          tags: ['LMS'],
          summary: 'Issue completion certificate',
          description: 'Issues a certificate for a completed course enrollment. Course must be 100% complete.',
          operationId: 'issueCertificate',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Enrollment UUID' },
          ],
          responses: {
            201: {
              description: 'Certificate issued',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/Certificate' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/lms/certificates/{number}/verify': {
        get: {
          tags: ['LMS'],
          summary: 'Verify a certificate by number (Public)',
          description: 'Public endpoint to verify the authenticity of a certificate.',
          operationId: 'verifyCertificate',
          security: [],
          parameters: [
            { in: 'path', name: 'number', required: true, schema: { type: 'string' }, description: 'Certificate number (e.g. CERT-2024-001234)', example: 'CERT-2024-001234' },
          ],
          responses: {
            200: {
              description: 'Certificate verification result',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: {
                        type: 'object',
                        properties: {
                          valid: { type: 'boolean', example: true },
                          certificateNumber: { type: 'string' },
                          status: { type: 'string', example: 'active' },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/api/v1/lms/dashboard': {
        get: {
          tags: ['LMS'],
          summary: 'LMS dashboard (enrolled courses, progress, certificates)',
          operationId: 'getLmsDashboard',
          security: [{ bearerAuth: [] }],
          responses: {
            200: { description: 'LMS dashboard data' },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // VENDORS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/vendors/my-bids': {
        get: {
          tags: ['Vendors'],
          summary: "Get vendor's submitted bids (Vendor)",
          operationId: 'getMyBids',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['pending', 'accepted', 'rejected'] } },
          ],
          responses: {
            200: {
              description: 'Vendor bids list',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/VendorBid' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/vendors/stats': {
        get: {
          tags: ['Vendors'],
          summary: 'Get vendor performance statistics (Vendor)',
          operationId: 'getVendorStats',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Vendor stats',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/VendorStats' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/vendors/jobs': {
        get: {
          tags: ['Vendors'],
          summary: 'Get vendor active/completed jobs (Vendor)',
          operationId: 'getVendorJobsAlt',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['assigned', 'in_progress', 'completed'] } },
          ],
          responses: {
            200: {
              description: 'Vendor jobs',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/VendorJob' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // UPLOADS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/uploads/property/{id}/image': {
        post: {
          tags: ['Uploads'],
          summary: 'Upload property image',
          description: 'Uploads an image to S3 and links it to the property. Max file size: 10MB.',
          operationId: 'uploadPropertyImage',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Property UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'multipart/form-data': {
                schema: {
                  type: 'object',
                  required: ['file'],
                  properties: {
                    file: { type: 'string', format: 'binary', description: 'Image file (jpg, png, webp)' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Image uploaded',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/UploadResult' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/uploads/work-order/{id}/photo': {
        post: {
          tags: ['Uploads'],
          summary: 'Upload work order photo (before/after)',
          description: 'Uploads a photo to S3 and attaches it to the work order.',
          operationId: 'uploadWorkOrderPhoto',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Work Order UUID' },
          ],
          requestBody: {
            required: true,
            content: {
              'multipart/form-data': {
                schema: {
                  type: 'object',
                  required: ['file'],
                  properties: {
                    file: { type: 'string', format: 'binary' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Photo uploaded',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/UploadResult' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/uploads/kyc/{docType}': {
        post: {
          tags: ['Uploads'],
          summary: 'Upload KYC identity document',
          description: 'Uploads a KYC document to S3 and initiates verification. docType must be: passport, drivers_license, national_id, or utility_bill.',
          operationId: 'uploadKycDocument',
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              in: 'path',
              name: 'docType',
              required: true,
              schema: { type: 'string', enum: ['passport', 'drivers_license', 'national_id', 'utility_bill'] },
              example: 'passport',
            },
          ],
          requestBody: {
            required: true,
            content: {
              'multipart/form-data': {
                schema: {
                  type: 'object',
                  required: ['file'],
                  properties: {
                    file: { type: 'string', format: 'binary' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Document uploaded and queued for review',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/UploadResult' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // CALENDAR
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/calendar/events': {
        post: {
          tags: ['Calendar'],
          summary: 'Create a calendar event',
          operationId: 'createCalendarEvent',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['title', 'startTime', 'endTime'],
                  properties: {
                    title: { type: 'string', example: 'Lease Renewal Meeting' },
                    description: { type: 'string', example: 'Discuss renewal terms with tenant' },
                    startTime: { type: 'string', format: 'date-time', example: '2024-06-15T10:00:00Z' },
                    endTime: { type: 'string', format: 'date-time', example: '2024-06-15T11:00:00Z' },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description: 'Event created',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/CalendarEvent' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },
      '/api/v1/calendar/google-link': {
        post: {
          tags: ['Calendar'],
          summary: 'Generate Google Calendar "Add Event" link',
          description: 'Returns a URL that opens Google Calendar with the event pre-filled.',
          operationId: 'generateGoogleCalendarLink',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['title', 'startTime', 'endTime'],
                  properties: {
                    title: { type: 'string', example: 'Lease Renewal Meeting' },
                    description: { type: 'string' },
                    startTime: { type: 'string', format: 'date-time', example: '2024-06-15T10:00:00Z' },
                    endTime: { type: 'string', format: 'date-time', example: '2024-06-15T11:00:00Z' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Google Calendar link generated',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: {
                        type: 'object',
                        properties: {
                          link: { type: 'string', format: 'uri', example: 'https://calendar.google.com/calendar/render?action=TEMPLATE&...' },
                        },
                      },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // AI ASSISTANT
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/ai/chat': {
        post: {
          tags: ['AI Assistant'],
          summary: 'Chat with AI property management assistant',
          description: 'Sends a message to the AI assistant. Optionally pass propertyId or leaseId for context-aware responses.',
          operationId: 'aiChat',
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['message'],
                  properties: {
                    message: { type: 'string', example: 'What are my options if a tenant is late on rent?' },
                    propertyId: { type: 'string', format: 'uuid', description: 'Optional property context' },
                    leaseId: { type: 'string', format: 'uuid', description: 'Optional lease context' },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: 'AI response',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { $ref: '#/components/schemas/AIChatMessage' },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // ADMIN
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/admin/dashboard': {
        get: {
          tags: ['Admin'],
          summary: 'Admin dashboard statistics (Admin+)',
          description: 'Returns platform-wide statistics: total users, properties, leases, revenue, and more.',
          operationId: 'getAdminDashboard',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'Admin dashboard data',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: {
                        type: 'object',
                        properties: {
                          totalUsers: { type: 'integer', example: 1200 },
                          totalProperties: { type: 'integer', example: 350 },
                          totalLeases: { type: 'integer', example: 280 },
                          totalRevenue: { type: 'number', example: 850000 },
                          pendingVerifications: { type: 'integer', example: 12 },
                          activeMaintenanceOrders: { type: 'integer', example: 45 },
                        },
                      },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/admin/audit-logs': {
        get: {
          tags: ['Admin'],
          summary: 'Get system audit logs (Admin+)',
          operationId: 'getAuditLogs',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
            { in: 'query', name: 'limit', schema: { type: 'integer', default: 50 } },
            { in: 'query', name: 'action', schema: { type: 'string' }, description: 'Filter by action type' },
            { in: 'query', name: 'userId', schema: { type: 'string', format: 'uuid' }, description: 'Filter by user' },
          ],
          responses: {
            200: {
              description: 'Audit log entries',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/AuditLog' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/admin/verification-queue': {
        get: {
          tags: ['Admin'],
          summary: 'Get KYC/document verification queue (Admin+)',
          operationId: 'getVerificationQueue',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'query', name: 'status', schema: { type: 'string', enum: ['pending', 'approved', 'rejected'] } },
          ],
          responses: {
            200: {
              description: 'Verification queue items',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/VerificationRequest' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/admin/verification-queue/{id}/approve': {
        post: {
          tags: ['Admin'],
          summary: 'Approve a KYC verification request (Admin+)',
          operationId: 'approveVerification',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Verification request UUID' },
          ],
          requestBody: {
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    notes: { type: 'string', example: 'Document verified successfully' },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Verification approved' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/admin/verification-queue/{id}/reject': {
        post: {
          tags: ['Admin'],
          summary: 'Reject a KYC verification request (Admin+)',
          operationId: 'rejectVerification',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'Verification request UUID' },
          ],
          requestBody: {
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    notes: { type: 'string', example: 'Document is blurry or unreadable. Please re-submit.' },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'Verification rejected' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/admin/users/{id}/suspend': {
        put: {
          tags: ['Admin'],
          summary: 'Suspend a user account (Super Admin only)',
          operationId: 'suspendUser',
          security: [{ bearerAuth: [] }],
          parameters: [
            { in: 'path', name: 'id', required: true, schema: { type: 'string', format: 'uuid' }, description: 'User UUID to suspend' },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['reason'],
                  properties: {
                    reason: { type: 'string', example: 'Violation of terms of service - fraudulent activity' },
                  },
                },
              },
            },
          },
          responses: {
            200: { description: 'User suspended' },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },
      '/api/v1/admin/system-health': {
        get: {
          tags: ['Admin'],
          summary: 'Get detailed system health metrics (Admin+)',
          operationId: 'getSystemHealth',
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: 'System health metrics',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      success: { type: 'boolean', example: true },
                      data: { type: 'array', items: { $ref: '#/components/schemas/SystemHealthMetric' } },
                    },
                  },
                },
              },
            },
            401: { $ref: '#/components/responses/Unauthorized' },
            403: { $ref: '#/components/responses/Forbidden' },
          },
        },
      },

      // ═══════════════════════════════════════════════════════════════════════
      // WEBHOOKS
      // ═══════════════════════════════════════════════════════════════════════
      '/api/v1/webhooks/stripe': {
        post: {
          tags: ['Webhooks'],
          summary: 'Stripe payment webhook handler',
          description: 'Handles Stripe events: payment_intent.succeeded, payment_intent.payment_failed, invoice.paid. The request body must be the raw payload (not JSON-parsed).',
          operationId: 'stripeWebhook',
          security: [],
          parameters: [
            {
              in: 'header',
              name: 'stripe-signature',
              required: false,
              schema: { type: 'string' },
              description: 'Stripe webhook signature (used to verify authenticity)',
            },
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  description: 'Raw Stripe event payload',
                },
              },
            },
          },
          responses: {
            200: {
              description: 'Webhook received and processed',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      received: { type: 'boolean', example: true },
                    },
                  },
                },
              },
            },
            400: { description: 'Invalid signature or malformed payload' },
          },
        },
      },
    },
  },
  apis: resolveApiGlobs(),
};

export const swaggerSpec = swaggerJsdoc(options);
