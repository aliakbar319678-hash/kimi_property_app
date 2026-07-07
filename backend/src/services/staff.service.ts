import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

const DEFAULT_STAFF_PERMISSIONS = {
  can_view_tickets: true,
  can_resolve_tickets: false,
  can_manage_payments: false,
  can_view_reports: true,
  can_manage_staff: false,
  can_manage_settings: false,
};

export class StaffService {
  /** Create a new staff user */
  static async create(data: {
    email: string;
    password: string;
    display_name: string;
    first_name?: string;
    last_name?: string;
    department?: string;
    permissions?: Record<string, boolean>;
    createdByUserId: string;
  }) {
    return withTransaction(async (client) => {
      const existing = await client.query(
        'SELECT id FROM users WHERE email = $1',
        [data.email]
      );
      if (existing.rows.length > 0)
        throw new AppError('Email already registered', 409);

      const hash = await bcrypt.hash(data.password, 12);
      const userId = uuidv4();

      const userRes = await client.query(
        `INSERT INTO users
           (id, email, password_hash, display_name, department, created_by, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, true)
         RETURNING id, email, display_name, department, is_active, created_at`,
        [
          userId,
          data.email,
          hash,
          data.display_name,
          data.department || null,
          data.createdByUserId,
        ]
      );

      const mergedPermissions = {
        ...DEFAULT_STAFF_PERMISSIONS,
        ...(data.permissions || {}),
      };

      await client.query(
        `INSERT INTO user_roles (user_id, role, is_primary, permissions)
         VALUES ($1, 'staff', true, $2)`,
        [userId, JSON.stringify(mergedPermissions)]
      );

      await client.query(
        `INSERT INTO user_profiles (user_id, legal_first_name, legal_last_name)
         VALUES ($1, $2, $3)`,
        [userId, data.first_name || null, data.last_name || null]
      );

      return { ...userRes.rows[0], permissions: mergedPermissions };
    });
  }

  /** List all staff members */
  static async list(page: number = 1, limit: number = 20) {
    const offset = (page - 1) * limit;
    const res = await query(
      `SELECT
         u.id, u.email, u.display_name, u.department, u.is_active,
         u.created_at, ur.permissions,
         creator.display_name AS created_by_name,
         (SELECT COUNT(*) FROM tickets t WHERE t.assigned_staff_id = u.id AND t.status NOT IN ('resolved','closed','cancelled')) AS open_ticket_count
       FROM users u
       JOIN user_roles ur ON ur.user_id = u.id AND ur.role = 'staff'
       LEFT JOIN users creator ON creator.id = u.created_by
       ORDER BY u.created_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    const countRes = await query(
      `SELECT COUNT(*) FROM users u
       JOIN user_roles ur ON ur.user_id = u.id AND ur.role = 'staff'`
    );
    return {
      data: res.rows,
      meta: { total: parseInt(countRes.rows[0].count, 10), page, limit },
    };
  }

  /** Get one staff member by ID */
  static async getById(staffId: string) {
    const res = await query(
      `SELECT
         u.id, u.email, u.display_name, u.department, u.is_active, u.created_at,
         ur.permissions,
         creator.display_name AS created_by_name
       FROM users u
       JOIN user_roles ur ON ur.user_id = u.id AND ur.role = 'staff'
       LEFT JOIN users creator ON creator.id = u.created_by
       WHERE u.id = $1`,
      [staffId]
    );
    if (res.rows.length === 0) throw new AppError('Staff member not found', 404);
    return res.rows[0];
  }

  /** Update staff details and/or permissions */
  static async update(
    staffId: string,
    data: {
      display_name?: string;
      department?: string;
      permissions?: Record<string, boolean>;
      is_active?: boolean;
    }
  ) {
    return withTransaction(async (client) => {
      // Verify they are indeed staff
      const check = await client.query(
        `SELECT id FROM user_roles WHERE user_id = $1 AND role = 'staff'`,
        [staffId]
      );
      if (check.rows.length === 0)
        throw new AppError('Staff member not found', 404);

      if (
        data.display_name !== undefined ||
        data.department !== undefined ||
        data.is_active !== undefined
      ) {
        await client.query(
          `UPDATE users
           SET display_name = COALESCE($1, display_name),
               department   = COALESCE($2, department),
               is_active    = COALESCE($3, is_active),
               updated_at   = NOW()
           WHERE id = $4`,
          [
            data.display_name ?? null,
            data.department ?? null,
            data.is_active ?? null,
            staffId,
          ]
        );
      }

      if (data.permissions !== undefined) {
        await client.query(
          `UPDATE user_roles
           SET permissions = $1
           WHERE user_id = $2 AND role = 'staff'`,
          [JSON.stringify(data.permissions), staffId]
        );
      }

      return this.getById(staffId);
    });
  }

  /** Soft-delete: deactivate a staff member */
  static async deactivate(staffId: string) {
    const res = await query(
      `UPDATE users SET is_active = false, updated_at = NOW()
       WHERE id = $1 AND EXISTS (
         SELECT 1 FROM user_roles WHERE user_id = $1 AND role = 'staff'
       )
       RETURNING id, email, is_active`,
      [staffId]
    );
    if (res.rows.length === 0)
      throw new AppError('Staff member not found', 404);
    return res.rows[0];
  }

  /** Re-activate a previously deactivated staff member */
  static async reactivate(staffId: string) {
    const res = await query(
      `UPDATE users SET is_active = true, updated_at = NOW()
       WHERE id = $1 AND EXISTS (
         SELECT 1 FROM user_roles WHERE user_id = $1 AND role = 'staff'
       )
       RETURNING id, email, is_active`,
      [staffId]
    );
    if (res.rows.length === 0)
      throw new AppError('Staff member not found', 404);
    return res.rows[0];
  }
}
