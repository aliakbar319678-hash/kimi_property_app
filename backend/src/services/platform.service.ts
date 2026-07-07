import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class PlatformService {
  /** Fetch the current platform settings row */
  static async getSettings() {
    const res = await query(
      `SELECT ps.*, u.display_name AS updated_by_name
       FROM platform_settings ps
       LEFT JOIN users u ON u.id = ps.updated_by
       LIMIT 1`
    );
    if (res.rows.length === 0) throw new AppError('Platform settings not found', 500);
    return res.rows[0];
  }

  /** Update platform fee percentage (admin only) */
  static async updateFee(feePercent: number, updatedByUserId: string) {
    if (feePercent < 0 || feePercent > 100) {
      throw new AppError('Platform fee must be between 0 and 100', 400);
    }
    const res = await query(
      `UPDATE platform_settings
       SET platform_fee_percentage = $1,
           updated_by = $2,
           updated_at = NOW()
       WHERE id = (SELECT id FROM platform_settings LIMIT 1)
       RETURNING *`,
      [feePercent, updatedByUserId]
    );
    if (res.rows.length === 0) throw new AppError('Platform settings not found', 500);
    return res.rows[0];
  }

  /** Update hold period in days */
  static async updateHoldPeriod(days: number, updatedByUserId: string) {
    if (days < 1 || days > 30) {
      throw new AppError('Hold period must be between 1 and 30 days', 400);
    }
    const res = await query(
      `UPDATE platform_settings
       SET hold_period_days = $1,
           updated_by = $2,
           updated_at = NOW()
       WHERE id = (SELECT id FROM platform_settings LIMIT 1)
       RETURNING *`,
      [days, updatedByUserId]
    );
    return res.rows[0];
  }

  /** Convenience: get just the fee percentage as a number */
  static async getCurrentFeePercent(): Promise<number> {
    const res = await query(
      'SELECT platform_fee_percentage FROM platform_settings LIMIT 1'
    );
    return parseFloat(res.rows[0]?.platform_fee_percentage ?? '8.00');
  }

  /** Convenience: get hold period in days */
  static async getHoldPeriodDays(): Promise<number> {
    const res = await query(
      'SELECT hold_period_days FROM platform_settings LIMIT 1'
    );
    return parseInt(res.rows[0]?.hold_period_days ?? '5', 10);
  }
}
