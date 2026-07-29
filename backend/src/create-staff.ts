import { AuthService } from './services/auth.service';
import { pool } from './db';

async function createStaff() {
  try {
    const user = await AuthService.register({
      email: 'staff@example.com',
      password: 'password123',
      role: 'staff',
      display_name: 'Test Staff',
      first_name: 'Test',
      last_name: 'Staff'
    });
    console.log('Staff created:', user);
  } catch (e) {
    console.error('Error:', e);
  } finally {
    await pool.end();
  }
}

createStaff();
