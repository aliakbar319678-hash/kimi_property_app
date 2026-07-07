import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class UserService {
  static async updateProfile(userId: string, data: any) {
    const allowed = ['legal_first_name', 'legal_last_name', 'display_name', 'date_of_birth', 'current_address', 'emergency_contact'];
    const updates: string[] = [];
    const values: any[] = [];
    let idx = 1;
    for (const key of allowed) {
      if (data[key] !== undefined) {
        updates.push(`${key} = $${idx}`);
        values.push(typeof data[key] === 'object' ? JSON.stringify(data[key]) : data[key]);
        idx++;
      }
    }
    if (updates.length === 0) throw new AppError('No valid fields to update', 400);
    values.push(userId);
    await query(`UPDATE user_profiles SET ${updates.join(', ')}, updated_at = NOW() WHERE user_id = $${idx}`, values);
    return { updated: true };
  }

  static async updateOnboarding(userId: string, step: number, data: any) {
    return withTransaction(async (client) => {
      const profileRes = await client.query('SELECT onboarding_step FROM user_profiles WHERE user_id = $1', [userId]);
      if (profileRes.rows.length === 0) throw new AppError('Profile not found', 404);
      const currentStep = profileRes.rows[0].onboarding_step;
      if (step !== currentStep && step !== currentStep + 1) {
        throw new AppError(`Invalid step progression. Current: ${currentStep}`, 400);
      }

      const updateFields: string[] = [];
      const values: any[] = [];
      let idx = 1;

      if (step === 1) {
        if (data.legalName) { updateFields.push(`legal_first_name = $${idx++}`); values.push(data.legalName); }
        if (data.dob) { updateFields.push(`date_of_birth = $${idx++}`); values.push(data.dob); }
        if (data.phone) { updateFields.push(`phone = $${idx++}`); values.push(data.phone); }
      }
      if (step === 2) {
        if (data.employment) { updateFields.push(`employment_data = $${idx++}`); values.push(JSON.stringify(data.employment)); }
      }
      if (step === 3) {
        if (data.documents) { updateFields.push(`documents = $${idx++}`); values.push(JSON.stringify(data.documents)); }
      }
      if (step === 4) {
        if (data.preferences) { updateFields.push(`preferences = $${idx++}`); values.push(JSON.stringify(data.preferences)); }
      }
      if (step === 5) {
        updateFields.push(`onboarding_completed = $${idx++}`); values.push(true);
      }

      updateFields.push(`onboarding_step = $${idx++}`); values.push(step === 5 ? 5 : step + 1);
      values.push(userId);

      await client.query(
        `UPDATE user_profiles SET ${updateFields.join(', ')}, updated_at = NOW() WHERE user_id = $${idx}`,
        values
      );

      if (step === 5) {
        await client.query("UPDATE users SET kyc_status = 'reviewing' WHERE id = $1", [userId]);
        await client.query(
          `INSERT INTO verification_cases (user_id, case_type, status) VALUES ($1, 'identity', 'pending_review')`,
          [userId]
        );
      }

      return { step: step === 5 ? 5 : step + 1, completed: step === 5 };
    });
  }

  static async uploadDocument(userId: string, docType: string, fileUrl: string) {
    await query(
      'INSERT INTO kyc_documents (user_id, doc_type, file_url) VALUES ($1, $2, $3)',
      [userId, docType, fileUrl]
    );
    return { uploaded: true };
  }

  static async getRoles(userId: string) {
    const res = await query('SELECT role, entity_id, is_primary FROM user_roles WHERE user_id = $1', [userId]);
    return res.rows;
  }

  static async addRole(userId: string, role: string, entityId?: string) {
    await query(
      'INSERT INTO user_roles (user_id, role, entity_id) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING',
      [userId, role, entityId || null]
    );
    return { added: true };
  }
}
