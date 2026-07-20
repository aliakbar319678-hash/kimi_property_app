import { query } from '../db';
import { AppError } from '../middleware/errorHandler';

export class AdService {
  static async create(data: any) {
    const sql = `
      INSERT INTO ads (title, description, ad_type, banner_url, target_roles, latitude, longitude, location, radius_meters, redirect_url, is_active)
      VALUES ($1, $2, $3, $4, $5, $6, $7, 
              CASE WHEN $6::double precision IS NOT NULL AND $7::double precision IS NOT NULL THEN ST_SetSRID(ST_MakePoint($7, $6), 4326) ELSE NULL END, 
              $8, $9, $10)
      RETURNING *
    `;
    const params = [
      data.title,
      data.description || null,
      data.adType,
      data.bannerUrl,
      data.targetRoles,
      data.latitude !== undefined ? data.latitude : null,
      data.longitude !== undefined ? data.longitude : null,
      data.radiusMeters !== undefined ? data.radiusMeters : null,
      data.redirectUrl || null,
      data.isActive !== false
    ];

    const res = await query(sql, params);
    return res.rows[0];
  }

  static async update(id: string, data: any) {
    const existing = await this.getById(id);

    const title = data.title !== undefined ? data.title : existing.title;
    const description = data.description !== undefined ? data.description : existing.description;
    const adType = data.adType !== undefined ? data.adType : existing.ad_type;
    const bannerUrl = data.bannerUrl !== undefined ? data.bannerUrl : existing.banner_url;
    const targetRoles = data.targetRoles !== undefined ? data.targetRoles : existing.target_roles;
    const latitude = data.latitude !== undefined ? data.latitude : existing.latitude;
    const longitude = data.longitude !== undefined ? data.longitude : existing.longitude;
    const radiusMeters = data.radiusMeters !== undefined ? data.radiusMeters : existing.radius_meters;
    const redirectUrl = data.redirectUrl !== undefined ? data.redirectUrl : existing.redirect_url;
    const isActive = data.isActive !== undefined ? data.isActive : existing.is_active;

    const sql = `
      UPDATE ads 
      SET title = $1, description = $2, ad_type = $3, banner_url = $4, target_roles = $5, 
          latitude = $6, longitude = $7, 
          location = CASE WHEN $6::double precision IS NOT NULL AND $7::double precision IS NOT NULL THEN ST_SetSRID(ST_MakePoint($7, $6), 4326) ELSE NULL END, 
          radius_meters = $8, redirect_url = $9, is_active = $10, updated_at = NOW()
      WHERE id = $11
      RETURNING *
    `;
    const params = [
      title,
      description,
      adType,
      bannerUrl,
      targetRoles,
      latitude !== undefined ? latitude : null,
      longitude !== undefined ? longitude : null,
      radiusMeters !== undefined ? radiusMeters : null,
      redirectUrl,
      isActive,
      id
    ];

    const res = await query(sql, params);
    if (res.rows.length === 0) throw new AppError('Ad not found', 404);
    return res.rows[0];
  }

  static async delete(id: string) {
    const res = await query('DELETE FROM ads WHERE id = $1 RETURNING *', [id]);
    if (res.rows.length === 0) throw new AppError('Ad not found', 404);
    return res.rows[0];
  }

  static async getAll(adType?: string) {
    let sql = 'SELECT * FROM ads';
    const params: any[] = [];
    
    if (adType) {
      sql += ' WHERE ad_type = $1';
      params.push(adType);
    }
    
    sql += ' ORDER BY created_at DESC';
    const res = await query(sql, params);
    return res.rows;
  }

  static async getById(id: string) {
    const res = await query('SELECT * FROM ads WHERE id = $1', [id]);
    if (res.rows.length === 0) throw new AppError('Ad not found', 404);
    return res.rows[0];
  }

  static async getDisplayAds(params: { lat?: number; lng?: number; roles: string[] }) {
    const { lat, lng, roles } = params;

    let sql = `
      SELECT id, title, description, ad_type, banner_url, target_roles, latitude, longitude, radius_meters, redirect_url, is_active, created_at, updated_at
      FROM ads
      WHERE is_active = true
        AND (target_roles = '{}' OR target_roles && $1::varchar[])
    `;
    const queryParams: any[] = [roles];

    if (lat !== undefined && lng !== undefined && !isNaN(lat) && !isNaN(lng)) {
      sql += ` AND (location IS NULL OR radius_meters IS NULL OR ST_DWithin(location, ST_SetSRID(ST_MakePoint($3, $2), 4326)::geography, radius_meters))`;
      queryParams.push(lat, lng);
    } else {
      sql += ` AND (location IS NULL OR radius_meters IS NULL)`;
    }

    sql += ` ORDER BY created_at DESC`;
    const res = await query(sql, queryParams);
    return res.rows;
  }
}
