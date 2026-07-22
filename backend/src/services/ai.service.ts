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
    let totalProperties = 0;
    let activeTenants = 0;
    let pendingMaint = 0;
    let rentCollected = 0;

    // 1. Gather DB Stats Safely
    try {
      const { query } = await import('../db');
      
      const propCountRes = await query('SELECT COUNT(*) as count FROM properties WHERE landlord_id = $1', [landlordId]);
      totalProperties = Number(propCountRes.rows[0]?.count || 0);

      const tenantCountRes = await query(`SELECT COUNT(*) as count FROM leases WHERE landlord_id = $1 AND status ILIKE 'active'`, [landlordId]);
      activeTenants = Number(tenantCountRes.rows[0]?.count || 0);

      const maintCountRes = await query(`SELECT COUNT(*) as count FROM work_orders WHERE landlord_id = $1 AND status ILIKE 'pending'`, [landlordId]);
      pendingMaint = Number(maintCountRes.rows[0]?.count || 0);

      const rentRes = await query(
        `SELECT COALESCE(SUM(amount), 0) as total FROM rent_payments rp 
         JOIN properties p ON p.id = rp.property_id 
         WHERE p.landlord_id = $1 AND rp.status ILIKE 'paid'`,
        [landlordId]
      );
      rentCollected = Number(rentRes.rows[0]?.total || 0);
    } catch (e) {
      console.error('[AI SERVICE] Error fetching DB stats:', e);
    }

    const stats = { totalProperties, activeTenants, pendingMaint, rentCollected };
    const userMsg = (message || '').trim();
    const lowerMsg = userMsg.toLowerCase();

    // 2. Attempt Real Gemini / OpenAI API Call if API key is present
    const apiKey = process.env.GEMINI_API_KEY || process.env.OPENAI_API_KEY;
    if (apiKey && userMsg) {
      try {
        if (process.env.GEMINI_API_KEY) {
          const systemPrompt = `You are PropAdmin AI Assistant, a helpful and intelligent property management assistant.
Current Landlord Portfolio Context:
- Active Properties: ${totalProperties}
- Active Tenants: ${activeTenants}
- Pending Maintenance Work Orders: ${pendingMaint}
- Total Rent Collected: $${rentCollected.toLocaleString()}

Instructions:
Respond to the user's message in a friendly, conversational tone.
If the user asks general questions, answer them accurately.
If the user asks about their properties, leases, maintenance, or finances, answer using the portfolio context above.`;

          const apiRes = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [
                { role: 'user', parts: [{ text: `${systemPrompt}\n\nUser Question: ${userMsg}` }] }
              ]
            })
          });

          if (apiRes.ok) {
            const data: any = await apiRes.json();
            const aiReply = data?.candidates?.[0]?.content?.parts?.[0]?.text;
            if (aiReply) {
              return { reply: aiReply.trim(), stats };
            }
          }
        } else if (process.env.OPENAI_API_KEY) {
          const OpenAI = (await import('openai')).default;
          const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
          const completion = await openai.chat.completions.create({
            model: 'gpt-3.5-turbo',
            messages: [
              {
                role: 'system',
                content: `You are PropAdmin AI Assistant. Current Context: ${totalProperties} properties, ${activeTenants} active tenants, ${pendingMaint} pending maintenance, $${rentCollected} rent collected.`
              },
              { role: 'user', content: userMsg }
            ]
          });
          const reply = completion.choices[0]?.message?.content;
          if (reply) return { reply: reply.trim(), stats };
        }
      } catch (llmError) {
        console.error('[AI SERVICE] LLM API call error, falling back to intent parser:', llmError);
      }
    }

    // 3. Regex & Intent-based Fallback (No hardcoded single message!)
    const { query } = await import('../db');

    // Greetings
    if (!userMsg || /^(hi|hello|hey|hlo|greetings|good morning|good afternoon|good evening)$/i.test(lowerMsg) || lowerMsg === 'hi' || lowerMsg === 'hello' || lowerMsg === 'hey') {
      return { reply: "Hello! I am your PropAdmin AI Assistant. How can I help you manage your properties today?", stats };
    }

    // Maintenance / Repairs
    if (lowerMsg.includes('maint') || lowerMsg.includes('work order') || lowerMsg.includes('repair') || lowerMsg.includes('fix') || lowerMsg.includes('issue')) {
      try {
        const maintRes = await query(
          `SELECT title FROM work_orders 
           WHERE landlord_id = $1 AND status ILIKE 'pending'
           ORDER BY created_at DESC LIMIT 5`,
          [landlordId]
        );
        let reply = `You currently have ${pendingMaint} pending maintenance request(s).`;
        if (maintRes.rows.length > 0) {
          const titles = maintRes.rows.map(r => `"${r.title}"`).join(', ');
          reply += ` Recent requests: ${titles}.`;
        } else {
          reply += ` No urgent maintenance tickets are pending right now.`;
        }
        return { reply, stats };
      } catch (_) {}
    }

    // Properties / Buildings
    if (lowerMsg.includes('property') || lowerMsg.includes('properties') || lowerMsg.includes('building') || lowerMsg.includes('unit')) {
      try {
        const propRes = await query(`SELECT name FROM properties WHERE landlord_id = $1 ORDER BY name ASC LIMIT 5`, [landlordId]);
        let reply = `You currently have ${totalProperties} active property(ies) in your portfolio.`;
        if (propRes.rows.length > 0) {
          const names = propRes.rows.map(r => r.name).join(', ');
          reply += ` Your properties include: ${names}.`;
        }
        return { reply, stats };
      } catch (_) {}
    }

    // Tenants / Leases
    if (lowerMsg.includes('tenant') || lowerMsg.includes('lease') || lowerMsg.includes('renter')) {
      try {
        const tenantRes = await query(
          `SELECT u.display_name, u.legal_first_name, u.legal_last_name 
           FROM leases l JOIN users u ON u.id = l.tenant_id 
           WHERE l.landlord_id = $1 AND l.status ILIKE 'active'
           ORDER BY l.created_at DESC LIMIT 5`,
          [landlordId]
        );
        let reply = `You have ${activeTenants} active tenant(s) with active leases.`;
        if (tenantRes.rows.length > 0) {
          const names = tenantRes.rows.map(r => r.display_name || `${r.legal_first_name || ''} ${r.legal_last_name || ''}`.trim()).filter(Boolean).join(', ');
          if (names) reply += ` Active tenants: ${names}.`;
        }
        return { reply, stats };
      } catch (_) {}
    }

    // Financials / Rent
    if (lowerMsg.includes('rent') || lowerMsg.includes('payment') || lowerMsg.includes('income') || lowerMsg.includes('finance') || lowerMsg.includes('money') || lowerMsg.includes('collected')) {
      return { reply: `Total rent collected is $${rentCollected.toLocaleString()}. You have ${totalProperties} properties generating income. Check Financial Overview for detailed transaction logs.`, stats };
    }

    // General knowledge questions (who is, what is, tell me, how to)
    if (/^(who|what|where|why|how|when|can you|tell me|is there)/i.test(lowerMsg)) {
      return { 
        reply: `I am your PropAdmin AI Assistant. I specialize in managing your property portfolio (${totalProperties} properties, ${activeTenants} active tenants, and ${pendingMaint} pending repairs). How can I assist with your properties today?`,
        stats 
      };
    }

    // Default dynamic summary
    return {
      reply: `I am here to assist you! Your portfolio summary: ${totalProperties} active properties, ${activeTenants} active tenants, and ${pendingMaint} pending maintenance request(s). Total rent collected: $${rentCollected.toLocaleString()}.`,
      stats
    };
  }
}
