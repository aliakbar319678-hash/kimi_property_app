# Missing Backend Endpoints (BACKEND_TODO.md)

This file tracks backend endpoints that are referenced by the mobile app frontend but are missing, incomplete, or not implemented in the Express backend.

## Landlord Portal

1. **Screening Application Review**
   - Missing: `GET /api/v1/screening/applications/:id`
   - Missing: `GET /api/v1/screening/applications/:id/credit-report`
   - Missing: `GET /api/v1/screening/applications/:id/background-check`
   - Missing: `POST /api/v1/screening/applications/:id/decision`
   - *Note:* The only existing screening endpoint is the tenant-facing `POST /api/v1/applications/:id/screening` (Stripe fee charge).

2. **Late Notices**
   - Missing: `GET /api/v1/payments/late-notices` (Or similar GET endpoint to list late tenants/leases)

3. **Calendar Events (Listing)**
   - Missing: `GET /api/v1/calendar/events`
   - *Note:* Currently, the backend only implements `POST /api/v1/calendar/events` and `POST /api/v1/calendar/google-link`.

4. **Marketing & Showings**
   - Missing: `GET /api/v1/marketing/showings` (Or similar GET endpoint to list showing slots)

5. **Move-Out Inspections**
   - Missing: `GET /api/v1/move-out/inspections/dashboard`

6. **Move-In Checklists**
   - Missing: `GET /api/v1/move-in/checklists/dashboard`
   - Missing: `POST /api/v1/move-in/checklists`
