import { query } from '../db';
import { Request } from 'express';

export class AuditService {
  /**
   * Log an action performed by a user to the audit_logs table.
   * 
   * @param userId The ID of the user performing the action
   * @param userRole The role of the user (e.g. 'landlord', 'tenant')
   * @param action A short string describing the action (e.g. 'created_property', 'signed_lease')
   * @param entityType The type of entity affected (e.g. 'property', 'lease', 'ticket')
   * @param entityId The ID of the affected entity
   * @param details Additional context or JSON data
   * @param req Optional Express Request to extract IP and User Agent
   */
  static async logAction(
    userId: string,
    userRole: string | undefined,
    action: string,
    entityType: string,
    entityId: string | null = null,
    details: any = {},
    req?: Request
  ) {
    const ipAddress = req ? req.ip || req.connection.remoteAddress : null;
    const userAgent = req ? req.headers['user-agent'] : null;

    try {
      await query(
        `INSERT INTO audit_logs (user_id, user_role, action, entity_type, entity_id, details, ip_address, user_agent, created_at) 
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())`,
        [
          userId,
          userRole || null,
          action,
          entityType,
          entityId,
          JSON.stringify(details),
          ipAddress,
          userAgent
        ]
      );
    } catch (err) {
      console.error('Failed to write audit log:', err);
      // We usually don't want audit logging failures to crash the main request
    }
  }

  /**
   * Get the activity history for a specific user.
   */
  static async getUserHistory(userId: string, limit: number = 50, offset: number = 0) {
    const result = await query(
      `SELECT id, action, entity_type, entity_id, details, created_at 
       FROM audit_logs 
       WHERE user_id = $1 
       ORDER BY created_at DESC 
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return result.rows;
  }
}
