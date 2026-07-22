import fs from 'fs';
import path from 'path';

// Mock S3 by saving files to local 'uploads' directory
const UPLOADS_DIR = path.join(__dirname, '../../uploads');

if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

export async function uploadToS3(key: string, body: Buffer, contentType: string, bucket?: string) {
  // Use replace to flatten the key into a single filename, or we could create subdirectories.
  // Creating subdirectories is safer if keys have folders.
  const filePath = path.join(UPLOADS_DIR, key);
  const dir = path.dirname(filePath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  
  fs.writeFileSync(filePath, body);
  return { key, bucket: bucket || 'local-bucket' };
}

export async function getSignedUrl(key: string, expiresInSeconds: number = 3600, bucket?: string) {
  const host = process.env.BASE_URL || 'http://192.168.1.14:5000';
  return `${host}/uploads/${key}`;
}

export async function deleteFromS3(key: string, bucket?: string) {
  const filePath = path.join(UPLOADS_DIR, key);
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

