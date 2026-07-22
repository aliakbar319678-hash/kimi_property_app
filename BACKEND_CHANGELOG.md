# PropAdmin Backend Changelog & Handover Documentation

**Date:** July 23, 2026  
**Target Audience:** Backend Engineering Team  
**Scope:** Landlord Portal APIs, Database Schema Updates, Financial Workflows, and AI Chatbot Engine  

---

## 1. Database Schema & Migration Updates

### A. New Table: `landlord_payout_accounts`
Stores bank payout settings configured by landlords in the Landlord Portal.
- `id` (UUID, Primary Key)
- `landlord_id` (UUID, Foreign Key -> `users(id)`, UNIQUE)
- `bank_name` (VARCHAR)
- `account_holder_name` (VARCHAR)
- `account_number` (VARCHAR)
- `routing_number` (VARCHAR)
- `payout_method` (VARCHAR, e.g., `'bank_transfer'`, `'stripe'`)
- `updated_at` (TIMESTAMP)

### B. Table Modifications & Constraints
- **`rent_payments`**: Updated manual recording logic to accept and persist custom `paid_date`, `due_date`, `payment_method`, `amount_paid`, and `amount_due` for offline payment records.
- **`transactions`**: Aligned insert statements in `FinanceService` to match table columns (`payer_id`, `payee_id`, `property_id`, `unit_id`, `lease_id`, `type`, `amount`, `currency`, `status`, `gateway`), excluding unsupported column mutations (`notes`).

---

## 2. Updated & New API Endpoints (`src/routes/`)

### A. Financial Routes (`src/routes/finance.routes.ts`)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/finance/payout-account` | Retrieves pre-filled bank payout settings for the authenticated landlord. |
| `POST` | `/api/v1/finance/payout-account` | Upserts bank payout settings (`bankName`, `accountHolderName`, `accountNumber`, `routingNumber`). |
| `POST` | `/api/v1/finance/invoices/record-manual` | Records offline manual rent payments. Accepts `{ leaseId, amount, paymentMethod, paymentDate, notes }`. Returns explicit non-500 JSON error objects on validation failure. |
| `GET` | `/api/v1/finance/invoices` | Fetches landlord invoices, `totalCollected`, and `totalOutstanding`. |

### B. AI Routes (`src/routes/ai.routes.ts`)
| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/v1/ai/landlord-chat` | Chatbot prompt handler. Returns `200 OK` JSON `{ "success": true, "reply": "..." }` to prevent mobile network exceptions. |

### C. Server Registration (`src/server.ts`)
- Verified `/api/v1/ai` router registration (`app.use('/api/v1/ai', aiRouter)`).

---

## 3. Service Logic Updates (`src/services/`)

### A. `FinanceService` (`src/services/finance.service.ts`)
- **`recordManualPayment`**:
  - Dynamically extracts `property_id`, `unit_id`, and `tenant_id` from active lease record if `leaseId` is provided.
  - If no `leaseId` is provided, safely falls back to the landlord's first active property instead of throwing unhandled exceptions.
  - Inserts entries into both `rent_payments` (status `'paid'`) and `transactions` (status `'completed'`) within a single database transaction (`withTransaction`).

### B. `AIService` (`src/services/ai.service.ts`)
- **`landlordChat(landlordId, message)`**:
  - **Context Gathering**: Safely queries PostgreSQL for portfolio stats (`totalProperties`, `activeTenants`, `pendingMaint`, `rentCollected`).
  - **LLM Integration**:
    - Supports Gemini API (`process.env.GEMINI_API_KEY`) via REST endpoint (`gemini-1.5-flash`).
    - Supports OpenAI API (`process.env.OPENAI_API_KEY`) via `openai` SDK.
    - System prompt dynamically injects live landlord database stats.
  - **Regex Intent Engine (Fallback)**:
    - Runs intent matching when no LLM key is provided or when LLM requests fail.
    - Matches: Greetings (`"hi"`, `"hello"`), Maintenance (`"work order"`, `"repair"`), Properties (`"building"`), Tenants (`"lease"`), Financials (`"rent"`), and General questions (`"who is..."`).
    - Prevents hardcoded single-string responses.

---

## 4. Environment Setup & Handover Notes

1. **Environment Variables**:
   Add the following keys to `backend/.env` for production AI capabilities:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   # OR
   OPENAI_API_KEY=your_openai_api_key_here
   ```
2. **Database Migrations**:
   Ensure all migration scripts (`npm run migrate`) are executed prior to deployment.
