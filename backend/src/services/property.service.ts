import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class PropertyService {
  static async create(data: any, landlordId: string) {
    return withTransaction(async (client) => {
      const regionRes = await client.query('SELECT id FROM regions WHERE code = $1', [data.regionCode || 'US-NYC']);
      const regionId = regionRes.rows[0]?.id;

      const propertyRes = await client.query(
        `INSERT INTO properties (landlord_id, manager_id, region_id, name, address_line1, address_line2, city, state_province, postal_code, country_code, type, amenities, description, location, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, ST_SetSRID(ST_MakePoint($14, $15), 4326), 'pending_verification')
         RETURNING *`,
        [landlordId, data.managerId || null, regionId, data.name, data.addressLine1, data.addressLine2 || null, data.city, data.stateProvince, data.postalCode, data.countryCode, data.type, JSON.stringify(data.amenities || []), data.description || null, data.location?.lng, data.location?.lat]
      );
      return propertyRes.rows[0];
    });
  }

  static async search(filters: any) {
    let sql = `SELECT p.*, u.id as unit_id, u.unit_number, u.bedrooms, u.bathrooms, u.square_feet, u.rent_amount, u.status as unit_status
               FROM properties p
               LEFT JOIN units u ON u.property_id = p.id
               WHERE p.status = 'active' AND p.verification_status = 'approved'`;
    const params: any[] = [];
    let idx = 1;

    if (filters.priceMin !== undefined || filters.priceMax !== undefined) {
      sql += ` AND u.rent_amount BETWEEN $${idx++} AND $${idx++}`;
      params.push(filters.priceMin || 0, filters.priceMax || 999999);
    }
    if (filters.beds !== undefined) {
      sql += ` AND u.bedrooms >= $${idx++}`;
      params.push(filters.beds);
    }
    if (filters.baths !== undefined) {
      sql += ` AND u.bathrooms >= $${idx++}`;
      params.push(filters.baths);
    }
    if (filters.radiusKm && filters.lat && filters.lng) {
      sql += ` AND ST_DWithin(p.location, ST_SetSRID(ST_MakePoint($${idx + 1}, $${idx}), 4326)::geography, $${idx + 2} * 1000)`;
      params.push(filters.lat, filters.lng, filters.radiusKm);
      idx += 3;
    }
    if (filters.amenities) {
      const ams = filters.amenities.split(',');
      sql += ` AND p.amenities @> $${idx++}`;
      params.push(JSON.stringify(ams));
    }
    if (filters.pets) {
      sql += ` AND p.amenities @> $${idx++}`;
      params.push(JSON.stringify(['pets']));
    }
    if (filters.availableFrom) {
      sql += ` AND u.available_date <= $${idx++}`;
      params.push(filters.availableFrom);
    }

    const countRes = await query(`SELECT COUNT(*) FROM (${sql}) AS count_query`, [...params]);
    const total = parseInt(countRes.rows[0].count, 10);

    const sortMap: Record<string, string> = {
      price_asc: 'u.rent_amount ASC',
      price_desc: 'u.rent_amount DESC',
      newest: 'p.created_at DESC',
      relevance: 'p.created_at DESC',
    };
    sql += ` ORDER BY ${sortMap[filters.sort] || sortMap.relevance}`;
    sql += ` LIMIT $${idx++} OFFSET $${idx++}`;
    params.push(filters.limit, (filters.page - 1) * filters.limit);

    const res = await query(sql, params);
    return { data: res.rows, meta: { total, page: filters.page, limit: filters.limit, pages: Math.ceil(total / filters.limit) } };
  }

  static async getById(id: string) {
    const propRes = await query(`
      SELECT 
        p.*,
        p.name as title,
        COALESCE(p.address_line1, p.city, 'Unknown Address') as location,
        json_build_object(
          'id', u.id,
          'display_name', u.display_name,
          'first_name', COALESCE(up.legal_first_name, split_part(u.display_name, ' ', 1)),
          'last_name', COALESCE(up.legal_last_name, split_part(u.display_name, ' ', 2)),
          'avatar_url', up.avatar_url
        ) as owner
      FROM properties p
      LEFT JOIN users u ON u.id = p.landlord_id
      LEFT JOIN user_profiles up ON up.user_id = p.landlord_id
      WHERE p.id = $1
    `, [id]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    const unitsRes = await query('SELECT * FROM units WHERE property_id = $1', [id]);
    const prop = propRes.rows[0];
    return { 
      ...prop, 
      units: unitsRes.rows,
      units_count: unitsRes.rows.length,
    };
  }

  static async createUnit(propertyId: string, data: any) {
    const res = await query(
      `INSERT INTO units (property_id, unit_number, bedrooms, bathrooms, square_feet, rent_amount, deposit_amount, status, available_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [propertyId, data.unitNumber, data.bedrooms, data.bathrooms, data.squareFeet, data.rentAmount, data.depositAmount, data.status || 'vacant', data.availableDate]
    );
    return res.rows[0];
  }

  static async saveProperty(userId: string, propertyId: string) {
    await query('INSERT INTO saved_properties (user_id, property_id) VALUES ($1, $2) ON CONFLICT DO NOTHING', [userId, propertyId]);
    return { saved: true };
  }

  static async getSaved(userId: string) {
    const res = await query(
      `SELECT p.* FROM properties p
       JOIN saved_properties sp ON sp.property_id = p.id
       WHERE sp.user_id = $1`,
      [userId]
    );
    return res.rows;
  }
}
