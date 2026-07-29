import Stripe from 'stripe';
import { query } from '../db';
import { AppError } from '../middleware/errorHandler';

// Initialize Stripe with the secret key from env
if (!process.env.STRIPE_SECRET_KEY) {
  console.error('⚠️  STRIPE_SECRET_KEY is not set — Stripe calls will fail!');
}
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
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
      const chargeOptions: Stripe.ChargeCreateParams = {
        amount: amountInCents,
        currency: 'usd',
        source: sourceToken,
        description: description,
      };

      if (destinationAccountId) {
        chargeOptions.transfer_data = {
          destination: destinationAccountId,
        };
        chargeOptions.application_fee_amount = platformFeeInCents;
      }



      const charge = await stripe.charges.create(chargeOptions);

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



      const refund = await stripe.refunds.create(refundOptions);
      return refund;
    } catch (error: any) {
      throw new AppError(`Refund failed: ${error.message}`, 400);
    }
  }

  /**
   * Transfers funds from the platform account to a connected Stripe account.
   */
  static async createTransfer(amountInCents: number, destinationAccountId: string, description?: string) {
    try {
      // Safety check: Don't attempt real transfers to dummy test accounts with live keys
      if (destinationAccountId.includes('dummy')) {
        console.log(`[Stripe Mock] Simulating transfer to dummy account: ${destinationAccountId}`);
        return {
          id: 'tr_mock_' + Math.random().toString(36).substr(2, 9),
          object: 'transfer',
          amount: amountInCents,
          currency: 'usd',
          destination: destinationAccountId
        } as unknown as Stripe.Transfer;
      }

      const transfer = await stripe.transfers.create({
        amount: amountInCents,
        currency: 'usd',
        destination: destinationAccountId,
        description: description || 'Vendor Payout',
      });

      return transfer;
    } catch (error: any) {
      throw new AppError(`Transfer failed: ${error.message}`, 400);
    }
  }
}
