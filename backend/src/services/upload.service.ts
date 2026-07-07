import { v4 as uuidv4 } from 'uuid';
import { uploadToS3, getSignedUrl } from '../utils/s3';
import { query } from '../db';

export class UploadService {
  static async uploadFile(buffer: Buffer, originalName: string, mimeType: string, entityType: string, entityId: string, userId: string) {
    const ext = originalName.split('.').pop() || 'bin';
    const key = `uploads/${entityType}/${entityId}/${uuidv4()}.${ext}`;
    await uploadToS3(key, buffer, mimeType);
    const url = await getSignedUrl(key, 86400 * 7); // 7 days

    // Log upload in audit
    await query(
      `INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, created_at)
       VALUES ($1, 'FILE_UPLOADED', $2, $3, $4, NOW())`,
      [userId, entityType, entityId, JSON.stringify({ key, mimeType, originalName })]
    );

    return { key, url, expiresIn: 86400 * 7 };
  }

  static async uploadPropertyImage(propertyId: string, buffer: Buffer, originalName: string, mimeType: string, userId: string) {
    const result = await this.uploadFile(buffer, originalName, mimeType, 'property', propertyId, userId);
    await query(
      `UPDATE properties SET images = COALESCE(images, '[]'::jsonb) || $1::jsonb WHERE id = $2`,
      [JSON.stringify([{ url: result.url, key: result.key, uploadedAt: new Date().toISOString() }]), propertyId]
    );
    return result;
  }

  static async uploadWorkOrderPhoto(workOrderId: string, buffer: Buffer, originalName: string, mimeType: string, userId: string) {
    const result = await this.uploadFile(buffer, originalName, mimeType, 'work_order', workOrderId, userId);
    await query(
      `UPDATE work_orders SET photos = COALESCE(photos, '[]'::jsonb) || $1::jsonb WHERE id = $2`,
      [JSON.stringify([{ url: result.url, key: result.key, uploadedAt: new Date().toISOString() }]), workOrderId]
    );
    return result;
  }

  static async uploadKycDocument(userId: string, docType: string, buffer: Buffer, originalName: string, mimeType: string) {
    const result = await this.uploadFile(buffer, originalName, mimeType, 'kyc', userId, userId);
    await query(
      `INSERT INTO kyc_documents (user_id, doc_type, file_url, verification_status) VALUES ($1, $2, $3, 'pending')`,
      [userId, docType, result.url]
    );
    return result;
  }
}
