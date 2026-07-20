import { query, withTransaction } from '../db';
import { AppError } from '../middleware/errorHandler';

export class UserService {
  static async updateProfile(userId: string, data: any) {
    // Normalize camelCase -> snake_case so frontend can send either format
    const normalized: any = { ...data };
    if (data.firstName !== undefined) normalized.legal_first_name = data.firstName;
    if (data.lastName !== undefined) normalized.legal_last_name = data.lastName;
    if (data.displayName !== undefined) normalized.display_name = data.displayName;
    if (data.phoneNumber !== undefined) normalized.phone = data.phoneNumber;
    if (data.dateOfBirth !== undefined) normalized.date_of_birth = data.dateOfBirth;
    if (data.currentAddress !== undefined) normalized.current_address = data.currentAddress;
    if (data.emergencyContact !== undefined) normalized.emergency_contact = data.emergencyContact;

    const userAllowed = ['legal_first_name', 'legal_last_name', 'display_name', 'phone'];
    const profileAllowed = ['date_of_birth', 'current_address', 'emergency_contact'];

    return withTransaction(async (client) => {
      const userUpdates: string[] = [];
      const userValues: any[] = [];
      let uIdx = 1;
      for (const key of userAllowed) {
        if (normalized[key] !== undefined) {
          userUpdates.push(`${key} = $${uIdx++}`);
          userValues.push(normalized[key]);
        }
      }
      if (userUpdates.length > 0) {
        userValues.push(userId);
        await client.query(`UPDATE users SET ${userUpdates.join(', ')}, updated_at = NOW() WHERE id = $${uIdx}`, userValues);
      }

      const profileUpdates: string[] = [];
      const profileValues: any[] = [];
      let pIdx = 1;
      for (const key of profileAllowed) {
        if (normalized[key] !== undefined) {
          profileUpdates.push(`${key} = $${pIdx++}`);
          profileValues.push(typeof normalized[key] === 'object' ? JSON.stringify(normalized[key]) : normalized[key]);
        }
      }
      if (profileUpdates.length > 0) {
        profileValues.push(userId);
        await client.query(`UPDATE user_profiles SET ${profileUpdates.join(', ')}, updated_at = NOW() WHERE user_id = $${pIdx}`, profileValues);
      }

      if (userUpdates.length === 0 && profileUpdates.length === 0) {
        throw new AppError('No valid fields to update', 400);
      }

      return { updated: true };
    });
  }

  static async updateOnboarding(userId: string, step: number, data: any) {
    return withTransaction(async (client) => {
      const profileRes = await client.query('SELECT onboarding_step, onboarding_completed FROM user_profiles WHERE user_id = $1', [userId]);
      if (profileRes.rows.length === 0) throw new AppError('Profile not found', 404);
      const currentStep = profileRes.rows[0].onboarding_step;
      const onboardingCompleted = profileRes.rows[0].onboarding_completed;
      // Allow: any previous step (re-submission), current step, or next step.
      // Block only if user tries to skip ahead (e.g. jump from step 1 to step 3).
      if (!onboardingCompleted && step > currentStep + 1) {
        throw new AppError(`Cannot skip steps. Current: ${currentStep}`, 400);
      }

      const updateFields: string[] = [];
      const values: any[] = [];
      let idx = 1;

      if (step === 1) {
        if (data.legalName) {
          const names = data.legalName.trim().split(/\s+/);
          const firstName = names[0] || '';
          const lastName = names.slice(1).join(' ') || '';
          await client.query('UPDATE users SET legal_first_name = $1, legal_last_name = $2 WHERE id = $3', [firstName, lastName, userId]);
        }
        if (data.phone) {
          await client.query('UPDATE users SET phone = $1 WHERE id = $2', [data.phone, userId]);
        }
        if (data.dob) {
          updateFields.push(`date_of_birth = $${idx++}`);
          values.push(data.dob);
        }
        if (data.address) {
          updateFields.push(`current_address = $${idx++}`);
          values.push(JSON.stringify(data.address));
        }
        if (data.emergencyContact) {
          updateFields.push(`emergency_contact = $${idx++}`);
          values.push(JSON.stringify(data.emergencyContact));
        }
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
