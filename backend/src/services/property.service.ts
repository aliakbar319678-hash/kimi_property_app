import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class PropertyService {
  static async create(data: any, landlordId: string) {
    return withTransaction(async (client) => {
      const regionRes = await client.query('SELECT id FROM regions WHERE code = $1', [data.regionCode || 'US-NYC']);
      const regionId = regionRes.rows[0]?.id;

      let locationSql = 'NULL';
      const values: any[] = [
        landlordId, data.managerId || null, regionId, data.name || 'Unnamed Property', 
        data.addressLine1 || '', data.addressLine2 || null, data.city || '', 
        data.stateProvince || '', data.postalCode || '', data.countryCode || 'US', 
        data.type || 'residential', JSON.stringify(data.amenities || []), 
        data.description || null
      ];
      if (data.location?.lng !== undefined && data.location?.lat !== undefined) {
        locationSql = `ST_SetSRID(ST_MakePoint($14, $15), 4326)`;
        values.push(data.location.lng, data.location.lat);
      }

      const propertyRes = await client.query(
        `INSERT INTO properties (landlord_id, manager_id, region_id, name, address_line1, address_line2, city, state_province, postal_code, country_code, type, amenities, description, status, location)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, 'pending_verification', ${locationSql})
         RETURNING *`,
        values
      );
      return propertyRes.rows[0];
    });
  }

  static async search(filters: any) {
    const parsedLimit = parseInt(filters.limit, 10);
    const limit = Math.max(1, isNaN(parsedLimit) ? 10 : parsedLimit);
    const parsedPage = parseInt(filters.page, 10);
    const page = Math.max(1, isNaN(parsedPage) ? 1 : parsedPage);
    const offset = (page - 1) * limit;

    let sql = `SELECT p.*, u.id as unit_id, u.unit_number, u.bedrooms, u.bathrooms, u.square_feet, u.rent_amount, u.status as unit_status
               FROM properties p
               LEFT JOIN units u ON u.property_id = p.id
               WHERE p.status = 'active' AND p.verification_status = 'approved'`;
    const params: any[] = [];
    let idx = 1;

    const priceMin = parseFloat(filters.priceMin);
    const priceMax = parseFloat(filters.priceMax);
    if (!isNaN(priceMin) || !isNaN(priceMax)) {
      sql += ` AND u.rent_amount BETWEEN $${idx++} AND $${idx++}`;
      params.push(isNaN(priceMin) ? 0 : priceMin, isNaN(priceMax) ? 999999 : priceMax);
    }
    
    const beds = parseInt(filters.beds, 10);
    if (!isNaN(beds)) {
      sql += ` AND u.bedrooms >= $${idx++}`;
      params.push(beds);
    }
    
    const baths = parseInt(filters.baths, 10);
    if (!isNaN(baths)) {
      sql += ` AND u.bathrooms >= $${idx++}`;
      params.push(baths);
    }
    
    const lat = parseFloat(filters.lat);
    const lng = parseFloat(filters.lng);
    const radiusKm = parseFloat(filters.radiusKm);
    if (!isNaN(radiusKm) && !isNaN(lat) && !isNaN(lng)) {
      sql += ` AND ST_DWithin(p.location, ST_SetSRID(ST_MakePoint($${idx + 1}, $${idx}), 4326)::geography, $${idx + 2} * 1000)`;
      params.push(lat, lng, radiusKm);
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
    params.push(limit, offset);

    const res = await query(sql, params);
    return { data: res.rows, meta: { total, page, limit, pages: Math.ceil(total / limit) } };
  }

  static async getById(id: string) {
    const propRes = await query('SELECT * FROM properties WHERE id = $1', [id]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    const unitsRes = await query('SELECT * FROM units WHERE property_id = $1', [id]);
    return { ...propRes.rows[0], units: unitsRes.rows };
  }

  static async createUnit(propertyId: string, data: any) {
    const rawRent = data.rentAmount !== undefined ? data.rentAmount : data.price;
    const rawDeposit = data.depositAmount !== undefined ? data.depositAmount : data.deposit;

    const rentAmount = rawRent ? parseFloat(rawRent) : null;
    const depositAmount = rawDeposit ? parseFloat(rawDeposit) : null;
    const bedrooms = data.bedrooms ? parseInt(data.bedrooms, 10) : 0;
    const bathrooms = data.bathrooms ? parseInt(data.bathrooms, 10) : 0;
    const squareFeet = data.squareFeet ? parseInt(data.squareFeet, 10) : 0;
    
    const res = await query(
      `INSERT INTO units (property_id, unit_number, bedrooms, bathrooms, square_feet, rent_amount, deposit_amount, status, available_date)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [
        propertyId, 
        data.unitNumber || 'Unit 1', 
        isNaN(bedrooms) ? 0 : bedrooms, 
        isNaN(bathrooms) ? 0 : bathrooms, 
        isNaN(squareFeet) ? 0 : squareFeet, 
        isNaN(rentAmount as any) ? null : rentAmount, 
        isNaN(depositAmount as any) ? null : depositAmount, 
        data.status || 'vacant', 
        data.availableDate || null
      ]
    );
    return res.rows[0];
  }

  static async update(id: string, data: any, userId: string, roles: string[]) {
    const propRes = await query('SELECT landlord_id FROM properties WHERE id = $1', [id]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    const isOwner = propRes.rows[0].landlord_id === userId;
    const isAdmin = roles.includes('admin') || roles.includes('super_admin');
    if (!isOwner && !isAdmin) {
      throw new AppError('Unauthorized to update this property', 403);
    }

    const allowedFields = [
      'name', 'address_line1', 'address_line2', 'city', 'state_province',
      'postal_code', 'country_code', 'type', 'status', 'verification_status',
      'amenities', 'description', 'images', 'rejection_reason', 'rejection_deadline'
    ];

    const updates: string[] = [];
    const values: any[] = [];
    let idx = 1;

    for (const field of allowedFields) {
      const bodyKey = field.replace(/_([a-z])/g, (g) => g[1].toUpperCase());
      const value = data[field] !== undefined ? data[field] : data[bodyKey];

      if (value !== undefined) {
        updates.push(`${field} = $${idx++}`);
        values.push((field === 'amenities' || field === 'images') && typeof value === 'object' ? JSON.stringify(value) : value);
      }
    }

    if (updates.length === 0) {
      throw new AppError('No valid fields to update', 400);
    }

    values.push(id);
    const updateRes = await query(
      `UPDATE properties SET ${updates.join(', ')}, updated_at = NOW() WHERE id = $${idx} RETURNING *`,
      values
    );

    return updateRes.rows[0];
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

  static async getByLandlordId(landlordId: string) {
    const res = await query(
      `SELECT p.*,
              COALESCE(COUNT(DISTINCT u.id), 0)::integer as total_units,
              COALESCE(COUNT(DISTINCT CASE WHEN u.status = 'occupied' THEN u.id END), 0)::integer as occupied_units,
              COALESCE(COUNT(DISTINCT CASE WHEN u.status = 'vacant' THEN u.id END), 0)::integer as vacant_units,
              COALESCE(SUM(CASE WHEN u.status = 'occupied' THEN u.rent_amount ELSE 0 END), 0)::float as monthly_rent
       FROM properties p
       LEFT JOIN units u ON u.property_id = p.id
       WHERE p.landlord_id = $1
       GROUP BY p.id`,
      [landlordId]
    );
    return res.rows;
  }

  static async resubmitProperty(propertyId: string, landlordId: string) {
    const propRes = await query('SELECT * FROM properties WHERE id = $1', [propertyId]);
    if (propRes.rows.length === 0) throw new AppError('Property not found', 404);
    
    if (propRes.rows[0].landlord_id !== landlordId) {
      throw new AppError('Unauthorized', 403);
    }

    if (propRes.rows[0].is_permanently_rejected) {
      throw new AppError('Property is permanently rejected and cannot be resubmitted', 400);
    }
    
    const historyEntry = { action: 'resubmit', by: landlordId, timestamp: new Date().toISOString() };
    
    await query(
      `UPDATE properties
       SET verification_status = 'resubmitted',
           resubmission_count = COALESCE(resubmission_count, 0) + 1,
           revision_history = COALESCE(revision_history, '[]'::jsonb) || $1::jsonb,
           updated_at = NOW()
       WHERE id = $2`,
      [JSON.stringify([historyEntry]), propertyId]
    );

    return { success: true };
  }
}
