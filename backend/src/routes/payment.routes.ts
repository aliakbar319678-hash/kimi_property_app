import { Router } from 'express';
import { authenticate, AuthRequest } from '../middleware/auth';
import { query } from '../db';
import { config } from '../config';
import Stripe from 'stripe';

const router = Router();
const stripe = new Stripe(config.stripe.secretKey || 'dummy_key', {
  apiVersion: '2023-08-16', // Adjust based on installed version or standard
});

// Helper function to get or create stripe customer
async function getOrCreateStripeCustomer(userId: string, email: string): Promise<string> {
  const result = await query('SELECT stripe_customer_id FROM users WHERE id = $1', [userId]);
  let customerId = result.rows[0]?.stripe_customer_id;

  if (!customerId) {
    const roleResult = await query('SELECT role FROM user_roles WHERE user_id = $1', [userId]);
    const userRole = roleResult.rows[0]?.role || 'unknown';

    const customer = await stripe.customers.create({
      email: email,
      metadata: { 
        userId,
        role: userRole
      },
    });
    customerId = customer.id;
    await query('UPDATE users SET stripe_customer_id = $1 WHERE id = $2', [customerId, userId]);
  }
  return customerId;
}

// 1. POST /setup-intent: Add a custom card
router.post('/setup-intent', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const userId = req.user!.id;
    const email = req.user!.email;

    const customerId = await getOrCreateStripeCustomer(userId, email);

    // Create an ephemeral key for the Customer
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: '2023-08-16' }
    );

    // Create a SetupIntent to save a card
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      payment_method_types: ['card'],
      usage: 'off_session',
    });

    res.json({
      status: 'success',
      client_secret: setupIntent.client_secret,
      ephemeral_key: ephemeralKey.secret,
      customer_id: customerId,
    });
  } catch (error) {
    next(error);
  }
});

// 2. GET /cards: Display saved cards (including default flag)
router.get('/cards', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const userId = req.user!.id;
    const result = await query('SELECT stripe_customer_id FROM users WHERE id = $1', [userId]);
    const customerId = result.rows[0]?.stripe_customer_id;

    if (!customerId) {
      return res.json({ status: 'success', cards: [] });
    }

    // Retrieve Stripe customer to check for default payment method
    const customer = await stripe.customers.retrieve(customerId);
    const defaultPaymentMethod = (customer as Stripe.Customer).invoice_settings?.default_payment_method;

    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    const cards = paymentMethods.data.map(pm => ({
      id: pm.id,
      brand: pm.card?.brand,
      last4: pm.card?.last4,
      exp_month: pm.card?.exp_month,
      exp_year: pm.card?.exp_year,
      is_default: pm.id === defaultPaymentMethod,
    }));

    res.json({ status: 'success', cards });
  } catch (error) {
    next(error);
  }
});

// 3. POST /cards/default: Set a card as primary/default
router.post('/cards/default', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { payment_method_id } = req.body;
    const userId = req.user!.id;

    if (!payment_method_id) {
      return res.status(400).json({ status: 'error', message: 'Payment method ID is required.' });
    }

    const result = await query('SELECT stripe_customer_id FROM users WHERE id = $1', [userId]);
    const customerId = result.rows[0]?.stripe_customer_id;

    if (!customerId) {
      return res.status(400).json({ status: 'error', message: 'Customer not found.' });
    }

    // Set as default payment method in Stripe customer settings
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: payment_method_id,
      },
    });

    res.json({ status: 'success', message: 'Default payment method updated successfully.' });
  } catch (error) {
    next(error);
  }
});

// 4. DELETE /cards/:id: Delete a saved card
router.delete('/cards/:id', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const { id } = req.params;
    
    // Detach the payment method
    await stripe.paymentMethods.detach(id);

    res.json({ status: 'success', message: 'Card deleted successfully.' });
  } catch (error) {
    next(error);
  }
});

// 5. POST /charge: Process a payment and log pending transaction in DB
router.post('/charge', authenticate, async (req: AuthRequest, res, next) => {
  let localTxId: string | null = null;
  try {
    const { amount, payment_method_id, payee_id, property_id, unit_id, lease_id, type } = req.body;
    const userId = req.user!.id;
    
    if (!amount || amount <= 0) {
      return res.status(400).json({ status: 'error', message: 'Invalid amount.' });
    }

    const result = await query('SELECT stripe_customer_id FROM users WHERE id = $1', [userId]);
    const customerId = result.rows[0]?.stripe_customer_id;

    if (!customerId) {
      return res.status(400).json({ status: 'error', message: 'Customer not found.' });
    }

    const txType = type || 'rent';
    const currency = 'USD';

    // 1. Create a pending transaction record in local database
    const dbTx = await query(
      `INSERT INTO transactions (payer_id, payee_id, property_id, unit_id, lease_id, type, amount, currency, status, gateway, metadata)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 'pending', 'stripe', $9)
       RETURNING id`,
      [
        userId,
        payee_id || null,
        property_id || null,
        unit_id || null,
        lease_id || null,
        txType,
        amount,
        currency,
        JSON.stringify({ payment_intent_id: null })
      ]
    );
    localTxId = dbTx.rows[0].id;

    let paymentIntent: any;
    let paymentSucceeded = false;
    let successfulCardId = null;
    let usedFallback = false;

    try {
      if (payment_method_id) {
        // First try the provided card
        try {
          paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100),
            currency: 'usd',
            customer: customerId,
            payment_method: payment_method_id,
            off_session: true,
            confirm: true,
          });
          paymentSucceeded = true;
        } catch (initialErr: any) {
          console.warn(`[POST /charge] Initial charge failed for ${payment_method_id}:`, initialErr.message);
          
          // Fallback logic: get all other cards
          const paymentMethods = await stripe.paymentMethods.list({ customer: customerId, type: 'card' });
          const otherCards = paymentMethods.data.filter(pm => pm.id !== payment_method_id);
          
          for (const card of otherCards) {
            try {
              paymentIntent = await stripe.paymentIntents.create({
                amount: Math.round(amount * 100),
                currency: 'usd',
                customer: customerId,
                payment_method: card.id,
                off_session: true,
                confirm: true,
              });
              
              if (paymentIntent.status === 'succeeded' || paymentIntent.status === 'requires_action') {
                paymentSucceeded = true;
                successfulCardId = card.id;
                usedFallback = true;
                break;
              }
            } catch (fallbackErr) {
              console.error(`[POST /charge] Fallback failed for card ${card.id}`);
            }
          }
          
          if (!paymentSucceeded) {
            // Throw the original error if all fallbacks fail
            throw initialErr;
          }
        }
        
        // If fallback succeeded, make it default and notify
        if (usedFallback && successfulCardId) {
          await stripe.customers.update(customerId, {
            invoice_settings: { default_payment_method: successfulCardId },
          });
          const { NotificationService } = require('../services/notification.service');
          await NotificationService.createPaymentFallbackSuccess(userId);
        }

      } else {
        // Create a PaymentIntent for the client to confirm with a new card
        paymentIntent = await stripe.paymentIntents.create({
          amount: Math.round(amount * 100),
          currency: 'usd',
          customer: customerId,
        });
      }

      // 2. Update transaction with Stripe PaymentIntent ID and update metadata
      await query(
        `UPDATE transactions 
         SET gateway_transaction_id = $1, 
             metadata = jsonb_set(metadata, '{payment_intent_id}', to_jsonb($1::text)) 
         WHERE id = $2`,
        [paymentIntent.id, localTxId]
      );

      res.json({
        status: 'success',
        transaction_id: paymentIntent.id,
        client_secret: paymentIntent.client_secret, // if client needs to confirm
        local_transaction_id: localTxId,
        used_fallback: usedFallback
      });

    } catch (stripeError: any) {
      // If Stripe call fails, update local transaction status to 'failed'
      if (localTxId) {
        await query(
          `UPDATE transactions 
           SET status = 'failed', 
               metadata = metadata || $1 
           WHERE id = $2`,
          [JSON.stringify({ failure_message: stripeError.message }), localTxId]
        );
        const { NotificationService } = require('../services/notification.service');
        await NotificationService.createPaymentFailedAlert(userId);
      }
      throw stripeError;
    }

  } catch (error) {
    next(error);
  }
});

// GET /payments/history - Tenant and Landlord view payment history
router.get('/history', authenticate, async (req: AuthRequest, res, next) => {
  try {
    const userId = req.user!.id;
    const role = req.user!.activeRole;
    let sql: string;
    let params: any[];
    if (role === 'tenant') {
      sql = `SELECT * FROM payments WHERE tenant_id = $1 ORDER BY created_at DESC`;
      params = [userId];
    } else {
      // Assume landlord or other role receives payments where they are payee
      sql = `SELECT * FROM payments WHERE payee_id = $1 ORDER BY created_at DESC`;
      params = [userId];
    }
    const result = await query(sql, params);
    res.json({ success: true, data: result.rows });
  } catch (e) { next(e); }
});

export { router as paymentRouter };
