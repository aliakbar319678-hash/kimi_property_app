import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '5000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  apiVersion: process.env.API_VERSION || 'v1',
  databaseUrl: process.env.DATABASE_URL || '',
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  jwtSecret: process.env.JWT_SECRET || 'default-secret-change-me',
  jwtExpiresIn: parseInt(process.env.JWT_EXPIRES_IN || '3600', 10),
  refreshTokenExpiresIn: parseInt(process.env.REFRESH_TOKEN_EXPIRES_IN || '604800', 10),
  bcryptRounds: parseInt(process.env.BCRYPT_ROUNDS || '12', 10),
  aws: {
    region: process.env.AWS_REGION || 'us-east-1',
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || '',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || '',
    s3Bucket: process.env.S3_BUCKET || 'propadmin-uploads',
    s3ExportBucket: process.env.S3_EXPORT_BUCKET || 'propadmin-exports',
  },
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY || '',
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
  },
  notifications: {
    fcmKey: process.env.FCM_SERVER_KEY || '',
    sendgridKey: process.env.SENDGRID_API_KEY || '',
    twilioSid: process.env.TWILIO_SID || '',
    twilioToken: process.env.TWILIO_AUTH_TOKEN || '',
    twilioPhone: process.env.TWILIO_PHONE || '',
  },
  urls: {
    web: process.env.WEB_APP_URL || 'http://localhost:3000',
    vendor: process.env.VENDOR_APP_URL || 'http://localhost:3001',
    admin: process.env.ADMIN_APP_URL || 'http://localhost:3002',
  },
};
