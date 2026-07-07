import Stripe from 'stripe';
import { query } from '../db';
import { AppError } from '../middleware/errorHandler';

// Initialize Stripe with the secret key from env
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_mock', {
  apiVersion: '2023-08-16',
});

export class StripeService {
  /**
   * Creates a Stripe Connect account for a landlord or vendor.
   */
  static async createConnectAccount(userId: string, email: string, role: string) {
    try {
      const account = await stripe.accounts.create({
        type: 'express',
        country: 'US', // Assuming US for now
        email: email,
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        metadata: {
          userId,
          role
        }
      });

      // Save to database
      await query(
        `UPDATE users SET stripe_account_id = $1, stripe_onboarding_status = 'pending' WHERE id = $2`,
        [account.id, userId]
      );

      return account;
    } catch (error: any) {
      throw new AppError(`Failed to create Stripe Connect account: ${error.message}`, 500);
    }
  }

  /**
   * Generates an onboarding link for the Connect account.
   */
  static async createAccountLink(accountId: string, returnUrl: string, refreshUrl: string) {
    try {
      const accountLink = await stripe.accountLinks.create({
        account: accountId,
        refresh_url: refreshUrl,
        return_url: returnUrl,
        type: 'account_onboarding',
      });
      return accountLink.url;
    } catch (error: any) {
      throw new AppError(`Failed to create Stripe onboarding link: ${error.message}`, 500);
    }
  }

  /**
   * Creates a destination charge.
   * Charges the tenant, but directly transfers the landlord's portion to their Connect account,
   * keeping the platform fee.
   */
  static async createDestinationCharge(
    amountInCents: number,
    platformFeeInCents: number,
    destinationAccountId: string,
    sourceToken: string, // e.g., token from frontend or saved customer payment method
    description: string
  ) {
    try {
      const charge = await stripe.charges.create({
        amount: amountInCents,
        currency: 'usd',
        source: sourceToken,
        description: description,
        transfer_data: {
          destination: destinationAccountId,
        },
        application_fee_amount: platformFeeInCents, // Platform keeps this amount
      });

      return charge;
    } catch (error: any) {
      throw new AppError(`Payment failed: ${error.message}`, 400);
    }
  }

  /**
   * Issues a refund.
   */
  static async issueRefund(chargeId: string, amountInCents?: number, reason?: string) {
    try {
      const refundOptions: Stripe.RefundCreateParams = {
        charge: chargeId,
      };
      
      if (amountInCents) {
        refundOptions.amount = amountInCents;
      }
      
      if (reason && (reason === 'duplicate' || reason === 'fraudulent' || reason === 'requested_by_customer')) {
          refundOptions.reason = reason;
      }

      // Mock response for development if it's a mock transaction or invalid key
      const isMockKey = !process.env.STRIPE_SECRET_KEY || 
                        process.env.STRIPE_SECRET_KEY === 'sk_test_mock' || 
                        process.env.STRIPE_SECRET_KEY === 'sk_test_';
                        
      if (chargeId.startsWith('mock_tx_') || isMockKey) {
        return {
          id: 're_mock_' + Math.random().toString(36).substr(2, 9),
          object: 'refund',
          amount: amountInCents || 1000,
          currency: 'usd',
          status: 'succeeded'
        };
      }

      const refund = await stripe.refunds.create(refundOptions);
      return refund;
    } catch (error: any) {
      throw new AppError(`Refund failed: ${error.message}`, 400);
    }
  }
}
