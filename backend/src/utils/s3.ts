import AWS from 'aws-sdk';
import { config } from '../config';

const s3 = new AWS.S3({
  region: config.aws.region,
  accessKeyId: config.aws.accessKeyId,
  secretAccessKey: config.aws.secretAccessKey,
});

export async function uploadToS3(key: string, body: Buffer, contentType: string, bucket?: string) {
  const targetBucket = bucket || config.aws.s3Bucket;
  await s3.putObject({ Bucket: targetBucket, Key: key, Body: body, ContentType: contentType }).promise();
  return { key, bucket: targetBucket };
}

export async function getSignedUrl(key: string, expiresInSeconds: number = 3600, bucket?: string) {
  const targetBucket = bucket || config.aws.s3Bucket;
  return s3.getSignedUrlPromise('getObject', { Bucket: targetBucket, Key: key, Expires: expiresInSeconds });
}

export async function deleteFromS3(key: string, bucket?: string) {
  const targetBucket = bucket || config.aws.s3Bucket;
  await s3.deleteObject({ Bucket: targetBucket, Key: key }).promise();
}
