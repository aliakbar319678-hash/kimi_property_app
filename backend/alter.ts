import { query } from './src/db';
query('ALTER TABLE invoices ADD COLUMN IF NOT EXISTS lease_id UUID REFERENCES leases(id), ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES users(id);')
  .then(() => console.log('done'))
  .catch(e => console.error(e))
  .finally(() => process.exit(0));
