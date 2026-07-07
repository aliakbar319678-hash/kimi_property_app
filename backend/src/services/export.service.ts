import { query } from '../db';
import { v4 as uuidv4 } from 'uuid';
import { uploadToS3, getSignedUrl } from '../utils/s3';
import { generatePDF } from './pdf.service';
import * as fastCsv from 'fast-csv';
import * as ExcelJS from 'exceljs';
import { Readable } from 'stream';

export class ExportService {
  static async createJob(userId: string, jobType: string, entityType: string, queryParams: any) {
    const id = uuidv4();
    await query(
      'INSERT INTO export_jobs (id, user_id, job_type, entity_type, query_params, status) VALUES ($1, $2, $3, $4, $5, $6)',
      [id, userId, jobType, entityType, JSON.stringify(queryParams), 'queued']
    );
    return { jobId: id, status: 'queued' };
  }

  static async processJob(jobId: string) {
    const jobRes = await query('SELECT * FROM export_jobs WHERE id = $1', [jobId]);
    if (jobRes.rows.length === 0) throw new Error('Job not found');
    const job = jobRes.rows[0];

    await query('UPDATE export_jobs SET status = $1 WHERE id = $2', ['processing', jobId]);

    try {
      let fileBuffer: Buffer;
      let contentType: string;
      let extension: string;

      if (job.job_type === 'csv') {
        const { buffer } = await this.generateCSV(job.entity_type, JSON.parse(job.query_params));
        fileBuffer = buffer;
        contentType = 'text/csv';
        extension = 'csv';
      } else if (job.job_type === 'excel') {
        const { buffer } = await this.generateExcel(job.entity_type, JSON.parse(job.query_params));
        fileBuffer = buffer;
        contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
        extension = 'xlsx';
      } else if (job.job_type === 'pdf') {
        const { buffer } = await this.generatePDFReport(job.entity_type, JSON.parse(job.query_params));
        fileBuffer = Buffer.from(buffer as any);
        contentType = 'application/pdf';
        extension = 'pdf';
      } else if (job.job_type === 'certificate_pdf') {
        const { buffer } = await generatePDF('certificate', JSON.parse(job.query_params));
        fileBuffer = Buffer.from(buffer as any);
        contentType = 'application/pdf';
        extension = 'pdf';
      } else {
        throw new Error('Unsupported export type');
      }

      const key = `exports/${jobId}.${extension}`;
      await uploadToS3(key, fileBuffer, contentType);
      const url = await getSignedUrl(key, 86400); // 24 hours

      await query(
        "UPDATE export_jobs SET status = $1, file_url = $2, completed_at = NOW(), expires_at = NOW() + INTERVAL '24 hours' WHERE id = $3",
        ['completed', url, jobId]
      );
    } catch (err) {
      await query('UPDATE export_jobs SET status = $1 WHERE id = $2', ['failed', jobId]);
      throw err;
    }
  }

  private static async generateCSV(entityType: string, params: any) {
    let sql = '';
    let queryParams: any[] = [];
    if (entityType === 'payments') {
      sql = 'SELECT * FROM rent_payments WHERE landlord_id = $1 ORDER BY created_at DESC';
      queryParams = [params.userId];
    } else if (entityType === 'audit_logs') {
      sql = 'SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT 10000';
    } else {
      sql = 'SELECT * FROM properties WHERE status = $1';
      queryParams = ['active'];
    }

    const res = await query(sql, queryParams);
    const rows = res.rows;
    const csvStream = fastCsv.format({ headers: true });
    const chunks: Buffer[] = [];
    csvStream.on('data', (chunk) => chunks.push(chunk));
    for (const row of rows) csvStream.write(row);
    csvStream.end();
    await new Promise((resolve) => csvStream.on('end', resolve));
    return { buffer: Buffer.concat(chunks) };
  }

  private static async generateExcel(entityType: string, params: any) {
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Data');
    let sql = '';
    let queryParams: any[] = [];
    if (entityType === 'payments') {
      sql = 'SELECT * FROM rent_payments WHERE landlord_id = $1 ORDER BY created_at DESC';
      queryParams = [params.userId];
    } else {
      sql = 'SELECT * FROM properties LIMIT 10000';
    }
    const res = await query(sql, queryParams);
    if (res.rows.length > 0) {
      worksheet.columns = Object.keys(res.rows[0]).map((key) => ({ header: key, key }));
      res.rows.forEach((row) => worksheet.addRow(row));
    }
    const buffer = await workbook.xlsx.writeBuffer();
    return { buffer: Buffer.from(buffer) };
  }

  private static async generatePDFReport(entityType: string, params: any) {
    // Uses Puppeteer via pdf.service
    const html = `<html><body><h1>${entityType} Report</h1><p>Generated at ${new Date().toISOString()}</p></body></html>`;
    const buffer = await generatePDF('report', { html });
    return { buffer };
  }
}
