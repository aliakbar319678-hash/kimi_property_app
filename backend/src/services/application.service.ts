import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';
import { StripeService } from './stripe.service';
import { PRICING, toCents } from '../config/pricing';

// ─────────────────────────────────────────────────────────
// Screening Provider Interface (Stub)
// Swap the implementation here when real provider is chosen
// (e.g. TransUnion, Checkr, FICO)
// ─────────────────────────────────────────────────────────
interface ScreeningResult {
  status: 'passed' | 'failed' | 'pending';
  reference: string;
  details?: Record<string, any>;
}

class MockScreeningProvider {
  async initiateCheck(applicationId: string): Promise<ScreeningResult> {
    // TODO: Replace with real provider API call
    console.log(`[SCREENING STUB] Initiating check for application ${applicationId}`);
    return {
      status: 'pending',
      reference: `MOCK-REF-${applicationId.slice(0, 8).toUpperCase()}`,
      details: { provider: 'mock', note: 'Stub — replace with real provider' },
    };
  }

  async getResult(providerRef: string): Promise<ScreeningResult> {
    // TODO: Replace with real provider webhook/polling
    return { status: 'passed', reference: providerRef };
  }
}

const screeningProvider = new MockScreeningProvider();

// ─────────────────────────────────────────────────────────
// Valid conditional approval tags (from PDF spec)
// ─────────────────────────────────────────────────────────
export const CONDITIONAL_TAGS = [
  'higher_security_deposit',
  'co_signer_required',
  'additional_income_docs',
  'secondary_screening',
  'short_term_lease_only',
  'resolve_issues_before_move_in',
] as const;

export type ConditionalTag = typeof CONDITIONAL_TAGS[number];

// ─────────────────────────────────────────────────────────
// Application Service
// ─────────────────────────────────────────────────────────
export class ApplicationService {

  /**
   * Create a draft application or update an existing draft.
   * Called per wizard step — data is merged, not replaced.
   */
  static async createOrUpdateDraft(tenantId: string, data: {
    unitId: string;
    propertyId: string;
    landlordId?: string;
    step: 1 | 2 | 3 | 4 | 5;
    personalInfo?: Record<string, any>;
    incomeEmployment?: Record<string, any>;
    referencesData?: any[];
    documents?: any[];
  }) {
    // Find existing draft for this tenant + unit
    const existing = await query(
      `SELECT id FROM applications WHERE tenant_id = $1 AND unit_id = $2 AND approval_status = 'pending' AND submitted_at IS NULL`,
      [tenantId, data.unitId]
    );

    if (existing.rows.length > 0) {
      // Update the existing draft
      const appId = existing.rows[0].id;
      const updates: string[] = ['current_step = $2', 'updated_at = NOW()'];
      const params: any[] = [appId, data.step];
      let idx = 3;

      if (data.personalInfo) { updates.push(`personal_info = $${idx++}`); params.push(JSON.stringify(data.personalInfo)); }
      if (data.incomeEmployment) { updates.push(`income_employment = $${idx++}`); params.push(JSON.stringify(data.incomeEmployment)); }
      if (data.referencesData) { updates.push(`references_data = $${idx++}`); params.push(JSON.stringify(data.referencesData)); }
      if (data.documents) { updates.push(`documents = $${idx++}`); params.push(JSON.stringify(data.documents)); }

      const res = await query(
        `UPDATE applications SET ${updates.join(', ')} WHERE id = $1 RETURNING *`,
        params
      );
      return res.rows[0];
    } else {
      // Verify unit exists and get landlord_id
      const unitRes = await query(
        `SELECT p.landlord_id FROM units u JOIN properties p ON p.id = u.property_id WHERE u.id = $1`,
        [data.unitId]
      );

      if (unitRes.rows.length === 0) {
        throw new AppError('Unit not found. Please provide a valid unitId.', 404);
      }

      const landlordId = data.landlordId || unitRes.rows[0].landlord_id;

      const res = await query(
        `INSERT INTO applications (tenant_id, unit_id, property_id, landlord_id, current_step,
          personal_info, income_employment, references_data, documents)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
        [
          tenantId, data.unitId, data.propertyId, landlordId, data.step,
          JSON.stringify(data.personalInfo || {}),
          JSON.stringify(data.incomeEmployment || {}),
          JSON.stringify(data.referencesData || []),
          JSON.stringify(data.documents || []),
        ]
      );
      return res.rows[0];
    }
  }

  /**
   * Final submit — marks the application as submitted
   */
  static async submitApplication(applicationId: string, tenantId: string) {
    const res = await query(
      `UPDATE applications SET submitted_at = NOW(), updated_at = NOW()
       WHERE id = $1 AND tenant_id = $2 AND submitted_at IS NULL RETURNING *`,
      [applicationId, tenantId]
    );
    if (res.rows.length === 0) throw new AppError('Application not found or already submitted', 404);
    return res.rows[0];
  }

  /**
   * Charge $50 screening fee via Stripe and initiate provider check
   */
  static async chargeScreeningFee(applicationId: string, tenantId: string, paymentMethodId: string) {
    const appRes = await query(
      'SELECT * FROM applications WHERE id = $1 AND tenant_id = $2',
      [applicationId, tenantId]
    );
    if (appRes.rows.length === 0) throw new AppError('Application not found', 404);
    const app = appRes.rows[0];
    if (app.screening_status !== 'not_started') {
      throw new AppError('Screening has already been initiated', 400);
    }

    // Charge $50 via Stripe
    const charge = await StripeService.createDestinationCharge(
      toCents(PRICING.tenant.screening_fee),
      0, // no platform split — full amount goes to platform
      '', // platform account
      paymentMethodId,
      `Tenant screening fee — Application ${applicationId}`
    );

    // Initiate screening stub
    const result = await screeningProvider.initiateCheck(applicationId);

    await query(
      `UPDATE applications SET
         screening_status = 'pending',
         screening_charge_id = $2,
         screening_provider_ref = $3,
         updated_at = NOW()
       WHERE id = $1`,
      [applicationId, charge.id, result.reference]
    );

    return { chargeId: charge.id, screeningRef: result.reference, status: 'pending' };
  }

  /**
   * Landlord updates application status (Approved / Rejected / Conditional Approval)
   */
  static async updateStatus(
    applicationId: string,
    landlordId: string,
    status: 'approved' | 'rejected' | 'conditional_approval',
    conditionalTerms?: { tags: ConditionalTag[]; note?: string }
  ) {
    if (status === 'conditional_approval' && !conditionalTerms?.tags?.length) {
      throw new AppError('Conditional approval requires at least one condition tag', 400);
    }

    // Validate tags
    if (conditionalTerms?.tags) {
      const invalid = conditionalTerms.tags.filter(t => !CONDITIONAL_TAGS.includes(t as any));
      if (invalid.length) throw new AppError(`Invalid condition tags: ${invalid.join(', ')}`, 400);
    }

    const res = await query(
      `UPDATE applications SET
         approval_status = $3,
         conditional_terms = $4,
         reviewed_at = NOW(),
         updated_at = NOW()
       WHERE id = $1 AND landlord_id = $2 RETURNING *`,
      [
        applicationId,
        landlordId,
        status,
        JSON.stringify(conditionalTerms || { tags: [], note: '' }),
      ]
    );
    if (res.rows.length === 0) throw new AppError('Application not found or not authorized', 404);
    return res.rows[0];
  }

  /**
   * Get all applications for a tenant (with property/unit info)
   */
  static async getTenantApplications(tenantId: string) {
    const res = await query(
      `SELECT a.*, p.name as property_name, u.unit_number, u.rent_amount
       FROM applications a
       JOIN properties p ON p.id = a.property_id
       JOIN units u ON u.id = a.unit_id
       WHERE a.tenant_id = $1
       ORDER BY a.created_at DESC`,
      [tenantId]
    );
    return res.rows;
  }

  /**
   * Get all applications for a landlord (for review)
   */
  static async getLandlordApplications(landlordId: string, status?: string) {
    let sql = `SELECT a.*,
                 COALESCE(a.screening_provider_ref, a.id::text) as screening_application_id,
                 u.unit_number, u.rent_amount,
                 p.name as property_name,
                 json_build_object('id', usr.id, 'display_name', usr.display_name, 'email', usr.email) as tenant
               FROM applications a
               JOIN units u ON u.id = a.unit_id
               JOIN properties p ON p.id = a.property_id
               JOIN users usr ON usr.id = a.tenant_id
               WHERE a.landlord_id = $1 AND a.submitted_at IS NOT NULL`;
    const params: any[] = [landlordId];
    if (status) { sql += ` AND a.approval_status = $2`; params.push(status); }
    sql += ` ORDER BY a.submitted_at DESC`;
    const res = await query(sql, params);
    return res.rows;
  }

  /**
   * Get a single application by ID
   */
  static async getById(applicationId: string, userId: string) {
    const res = await query(
      `SELECT a.*,
         COALESCE(a.screening_provider_ref, a.id::text) as screening_application_id,
         p.name as property_name, u.unit_number
       FROM applications a
       JOIN properties p ON p.id = a.property_id
       JOIN units u ON u.id = a.unit_id
       WHERE a.id = $1 AND (a.tenant_id = $2 OR a.landlord_id = $2)`,
      [applicationId, userId]
    );
    if (res.rows.length === 0) throw new AppError('Application not found', 404);
    return res.rows[0];
  }

  /**
   * Admin: get all applications
   */
  static async getAllForAdmin(page = 1, limit = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      `SELECT a.*,
         COALESCE(a.screening_provider_ref, a.id::text) as screening_application_id,
         p.name as property_name, u.unit_number,
         usr.display_name as tenant_name, usr.email as tenant_email
       FROM applications a
       JOIN properties p ON p.id = a.property_id
       JOIN units u ON u.id = a.unit_id
       JOIN users usr ON usr.id = a.tenant_id
       ORDER BY a.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    const countRes = await query('SELECT COUNT(*) FROM applications');
    return {
      data: res.rows,
      meta: { total: parseInt(countRes.rows[0].count, 10), page, limit },
    };
  }
}
