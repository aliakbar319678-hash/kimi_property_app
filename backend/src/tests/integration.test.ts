import request from 'supertest';
import { app, httpServer } from '../server';
import { pool } from '../db';

describe('PropAdmin Integration Tests', () => {
  beforeAll(async () => {
    // any setup
  });

  afterAll(async () => {
    await pool.end();
    httpServer.close();
  });

  describe('Auth Flow', () => {
    it('should login an existing admin user', async () => {
      const res = await request(app)
        .post('/api/v1/auth/login')
        .send({
          email: 'admin@propadmin.io',
          password: 'Admin123!'
        });
      
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('accessToken');
    });
  });
});
