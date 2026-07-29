/**
 * Pricing Configuration — Single Source of Truth
 * All monetary values in USD.
 * Import this wherever prices are referenced in code.
 */
export const PRICING = {
  landlord: {
    setup_fee: 49.99,
    per_unit_monthly: 9.99,
    listing_fee: 9.99,
    renewal_fee: 25.00,
  },
  tenant: {
    registration: 0,
    screening_fee: 50.00,   // $50 one-time screening charge per application
    application_fee: 0,
  },
  vendor: {
    registration_fee: 19.99,       // UPDATED from $119.99 per PDF spec
    monthly_subscription: 9.99,
    service_fee_percent: 0.04,     // 4% platform service fee on completed jobs
  },
  lms: {
    standalone_monthly: 19.99,
    with_registration: 0,          // Free when bundled with landlord/tenant registration
    eligible_roles: ['tenant', 'landlord', 'admin', 'staff'] as string[],
  },
} as const;

/** Amount in cents for Stripe (multiply dollars by 100) */
export function toCents(amount: number): number {
  return Math.round(amount * 100);
}
