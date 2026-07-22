import { AppError } from '../middleware/errorHandler';

export class AIService {
  static async chat(message: string, context: { userId: string; role: string; propertyId?: string; leaseId?: string }) {
    // Placeholder for OpenAI/Claude integration
    // In production: call openai.chat.completions.create({ model: 'gpt-4', messages: [...] })

    const lowerMsg = message.toLowerCase();

    if (lowerMsg.includes('lease') || lowerMsg.includes('expiring')) {
      return {
        response: `I've analyzed your portfolio. You have 3 leases expiring within 30 days and 2 maintenance tickets flagged as high priority. Would you like me to generate renewal offers or show the expiring lease details?`,
        suggestedActions: [
          { label: 'Show expiring leases', action: 'navigate', url: '/leases/expiring' },
          { label: 'Generate renewal report', action: 'download', url: '/exports/leases' },
        ],
        source: 'system_analysis',
      };
    }

    if (lowerMsg.includes('payment') || lowerMsg.includes('rent')) {
      return {
        response: `Your total collected this month is $24,500 (+12.4% from last month). You have $3,200 outstanding from 4 properties. Should I send reminder notifications?`,
        suggestedActions: [
          { label: 'Send reminders', action: 'api', method: 'POST', url: '/finance/payments/reminders' },
          { label: 'View details', action: 'navigate', url: '/finance' },
        ],
        source: 'system_analysis',
      };
    }

    return {
      response: `Hello! I'm your PropAdmin assistant. I can help you with lease management, rent tracking, maintenance scheduling, and property analytics. What would you like to know?`,
      suggestedActions: [],
      source: 'default',
    };
  }

  static async landlordChat(landlordId: string, message: string) {
    const { query } = await import('../db');
    const lowerMsg = (message || '').toLowerCase();

    // Fetch real-time DB stats for this landlord
    const propRes = await query('SELECT COUNT(*) as count FROM properties WHERE landlord_id = $1', [landlordId]);
    const totalProperties = Number(propRes.rows[0]?.count || 0);

    const tenantRes = await query('SELECT COUNT(DISTINCT tenant_id) as count FROM leases WHERE landlord_id = $1 AND status = \'active\'', [landlordId]);
    const activeTenants = Number(tenantRes.rows[0]?.count || 0);

    const maintRes = await query(
      `SELECT COUNT(*) as count FROM maintenance_requests mr 
       JOIN properties p ON p.id = mr.property_id 
       WHERE p.landlord_id = $1 AND mr.status IN ('pending', 'assigned', 'in_progress')`,
      [landlordId]
    );
    const pendingMaint = Number(maintRes.rows[0]?.count || 0);

    const rentRes = await query(
      `SELECT COALESCE(SUM(amount_paid), 0) as total FROM rent_payments rp 
       JOIN properties p ON p.id = rp.property_id 
       WHERE p.landlord_id = $1 AND rp.status = 'paid' AND rp.due_date >= DATE_TRUNC('month', CURRENT_DATE)`,
      [landlordId]
    );
    const rentCollected = Number(rentRes.rows[0]?.total || 0);

    let reply = '';
    if (lowerMsg.includes('rent') || lowerMsg.includes('collected') || lowerMsg.includes('finance')) {
      reply = `So far this month, you have collected $${rentCollected.toLocaleString()} in rent across your ${totalProperties} properties.`;
    } else if (lowerMsg.includes('maintenance') || lowerMsg.includes('work order') || lowerMsg.includes('pending')) {
      reply = `You currently have ${pendingMaint} pending or in-progress maintenance request(s).`;
    } else if (lowerMsg.includes('tenant') || lowerMsg.includes('active')) {
      reply = `You have ${activeTenants} active tenant(s) across your portfolio of ${totalProperties} property(ies).`;
    } else if (lowerMsg.includes('property') || lowerMsg.includes('portfolio') || lowerMsg.includes('total')) {
      reply = `Your portfolio currently consists of ${totalProperties} property(ies) with ${activeTenants} active lease(s).`;
    } else {
      reply = `Here is your portfolio overview: You manage ${totalProperties} property(ies) with ${activeTenants} active tenant(s). This month, total rent collected is $${rentCollected.toLocaleString()}, and there are ${pendingMaint} pending maintenance item(s). How else can I assist you today?`;
    }

    return {
      reply,
      stats: {
        totalProperties,
        activeTenants,
        pendingMaint,
        rentCollected
      }
    };
  }
}
