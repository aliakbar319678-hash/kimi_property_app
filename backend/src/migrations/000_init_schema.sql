-- ==========================================
-- PropAdmin Unified Schema v2.0
-- ==========================================

-- Extensions
-- CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Regions (Multi-tenancy localization)
CREATE TABLE regions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,  -- US-NYC, SA-RUH, GB-LON
    name VARCHAR(100) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    locale VARCHAR(10) NOT NULL DEFAULT 'en-US',
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    tax_config JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    legal_first_name VARCHAR(100),
    legal_last_name VARCHAR(100),
    display_name VARCHAR(100),
    avatar_url VARCHAR(500),
    kyc_status VARCHAR(20) DEFAULT 'pending' CHECK (kyc_status IN ('pending','reviewing','approved','rejected','suspended')),
    fraud_score SMALLINT DEFAULT 0 CHECK (fraud_score BETWEEN 0 AND 100),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    region_id UUID REFERENCES regions(id),
    preferred_language VARCHAR(5) DEFAULT 'en-US',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Role Context Switching (Resolves BUG-003)
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('super_admin','admin','landlord','property_manager','tenant','vendor','lms_instructor')),
    entity_id UUID,  -- property_id or vendor_org_id context
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role, entity_id)
);

-- User Profiles / Onboarding
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    current_address JSONB DEFAULT '{}',
    emergency_contact JSONB DEFAULT '{}',  -- {name, relationship, phone}
    employment_data JSONB DEFAULT '{}',    -- {company, salary, length, proof_url}
    onboarding_step SMALLINT DEFAULT 1 CHECK (onboarding_step BETWEEN 1 AND 5),
    onboarding_total_steps SMALLINT DEFAULT 5,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    documents JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- KYC Documents
CREATE TABLE kyc_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    doc_type VARCHAR(50) NOT NULL,  -- passport, id_card, proof_of_income, etc.
    file_url VARCHAR(500) NOT NULL,
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending','approved','rejected')),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Verification Cases (Fraud + KYC queue)
CREATE TABLE verification_cases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    case_type VARCHAR(50) NOT NULL CHECK (case_type IN ('identity','income','employment','fraud_review')),
    status VARCHAR(20) DEFAULT 'pending_review' CHECK (status IN ('pending_review','approved','rejected','escalated')),
    assigned_admin_id UUID REFERENCES users(id),
    risk_flags JSONB DEFAULT '[]',
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Properties
CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    landlord_id UUID REFERENCES users(id),
    manager_id UUID REFERENCES users(id),
    region_id UUID REFERENCES regions(id),
    name VARCHAR(255) NOT NULL,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country_code VARCHAR(2) DEFAULT 'US',
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    type VARCHAR(50) CHECK (type IN ('apartment','house','commercial','loft','studio')),
    status VARCHAR(20) DEFAULT 'pending_verification' CHECK (status IN ('active','inactive','pending_verification')),
    amenities JSONB DEFAULT '[]',
    description TEXT,
    images JSONB DEFAULT '[]',
    verification_status VARCHAR(20) DEFAULT 'pending' CHECK (verification_status IN ('pending','approved','rejected')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Units
CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    unit_number VARCHAR(50) NOT NULL,
    bedrooms SMALLINT,
    bathrooms SMALLINT,
    square_feet INT,
    rent_amount DECIMAL(12,2),
    deposit_amount DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'vacant' CHECK (status IN ('vacant','occupied','maintenance','reserved')),
    available_date DATE,
    floor_plan_url VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved Properties
CREATE TABLE saved_properties (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, property_id)
);

-- Leases
CREATE TABLE leases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES users(id),
    unit_id UUID REFERENCES units(id),
    property_id UUID REFERENCES properties(id),
    landlord_id UUID REFERENCES users(id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    rent_amount DECIMAL(12,2) NOT NULL,
    deposit_amount DECIMAL(12,2),
    payment_schedule VARCHAR(20) DEFAULT 'monthly' CHECK (payment_schedule IN ('monthly','weekly','bi_weekly')),
    payment_due_day SMALLINT DEFAULT 1,
    auto_renew BOOLEAN DEFAULT FALSE,
    renewal_notice_days SMALLINT DEFAULT 30,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft','active','expiring','terminated','renewed')),
    utilities_included JSONB DEFAULT '[]',
    documents JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT lease_date_check CHECK (end_date > start_date + INTERVAL '1 day')
);

CREATE UNIQUE INDEX idx_leases_unique_active ON leases(tenant_id, unit_id, status) WHERE status IN ('active','expiring');

-- Rent Payments
CREATE TABLE rent_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lease_id UUID REFERENCES leases(id),
    tenant_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    unit_id UUID REFERENCES units(id),
    amount_due DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) DEFAULT 0.00,
    balance_due DECIMAL(12,2) GENERATED ALWAYS AS (amount_due - amount_paid) STORED,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','partial','paid','late','failed','disputed')),
    due_date DATE NOT NULL,
    paid_date DATE,
    payment_method VARCHAR(50),
    gateway_transaction_id VARCHAR(255),
    invoice_url VARCHAR(500),
    reminder_sent BOOLEAN DEFAULT FALSE,
    late_fee_applied DECIMAL(8,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transactions (Unified Ledger)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payer_id UUID REFERENCES users(id),
    payee_id UUID REFERENCES users(id),
    property_id UUID REFERENCES properties(id),
    unit_id UUID REFERENCES units(id),
    lease_id UUID REFERENCES leases(id),
    type VARCHAR(50) NOT NULL CHECK (type IN ('rent','deposit','vendor_payout','refund','late_fee','maintenance_charge','platform_fee')),
    amount DECIMAL(12,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    amount_in_usd DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','failed','disputed','chargeback')),
    gateway VARCHAR(50),
    gateway_transaction_id VARCHAR(255),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoices
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID REFERENCES users(id),
    work_order_id UUID,
    invoice_number VARCHAR(50) UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) GENERATED ALWAYS AS (amount + tax_amount) STORED,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft','sent','pending','paid','overdue')),
    due_date DATE,
    paid_date DATE,
    file_url VARCHAR(500),
    items JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Work Orders
CREATE TABLE work_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id),
    unit_id UUID REFERENCES units(id),
    tenant_id UUID REFERENCES users(id),
    landlord_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50) CHECK (category IN ('general_repair','plumbing','electrical','hvac','appliance','painting','other')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low','medium','high','emergency')),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open','scheduled','in_progress','waiting_parts','completed','cancelled')),
    budget_min DECIMAL(10,2),
    budget_max DECIMAL(10,2),
    currency VARCHAR(3) NOT NULL,
    assigned_vendor_id UUID REFERENCES users(id),
    scheduled_date TIMESTAMPTZ,
    completed_date TIMESTAMPTZ,
    photos JSONB DEFAULT '[]',
    access_instructions TEXT,
    notify_tenant BOOLEAN DEFAULT TRUE,
    notify_vendor BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT waiting_parts_requires_vendor CHECK (status != 'waiting_parts' OR assigned_vendor_id IS NOT NULL)
);

-- Bids
CREATE TABLE bids (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    work_order_id UUID REFERENCES work_orders(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES users(id),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    message TEXT,
    estimated_hours SMALLINT,
    proposed_date TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected','withdrawn')),
    is_fixed_price BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Job Assignments
CREATE TABLE job_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    work_order_id UUID REFERENCES work_orders(id),
    bid_id UUID REFERENCES bids(id),
    vendor_id UUID REFERENCES users(id),
    final_amount DECIMAL(10,2),
    scheduled_date TIMESTAMPTZ,
    chat_room_id UUID,
    status VARCHAR(20) DEFAULT 'assigned' CHECK (status IN ('assigned','in_progress','completed','disputed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Inventory
CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id),
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100),
    quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 5,
    unit_cost DECIMAL(10,2),
    supplier_info JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE work_order_parts (
    work_order_id UUID REFERENCES work_orders(id),
    inventory_item_id UUID REFERENCES inventory_items(id),
    quantity_needed INT,
    quantity_used INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'needed' CHECK (status IN ('needed','ordered','received','used')),
    PRIMARY KEY (work_order_id, inventory_item_id)
);

-- Chat
CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(20) NOT NULL CHECK (type IN ('direct','job','group','support')),
    title VARCHAR(255),
    entity_id UUID,
    bid_visibility VARCHAR(20) DEFAULT 'landlord_vendor_only' CHECK (bid_visibility IN ('full','landlord_vendor_only')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE chat_participants (
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('landlord','vendor','tenant','admin','system')),
    can_view_bids BOOLEAN DEFAULT FALSE,
    can_view_costs BOOLEAN DEFAULT FALSE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    last_read_at TIMESTAMPTZ,
    PRIMARY KEY (room_id, user_id)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id),
    content TEXT,
    attachments JSONB DEFAULT '[]',
    reply_to_id UUID REFERENCES messages(id),
    read_by JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LMS: Courses
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    category VARCHAR(50) CHECK (category IN ('compliance','finance','maintenance','legal','strategy')),
    difficulty VARCHAR(20) CHECK (difficulty IN ('beginner','intermediate','advanced')),
    duration_minutes INT,
    instructor_name VARCHAR(100),
    description TEXT,
    thumbnail_url VARCHAR(500),
    certificate_template VARCHAR(100) DEFAULT 'standard',
    passing_score SMALLINT DEFAULT 70,
    is_published BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255),
    description TEXT,
    sort_order INT,
    content_type VARCHAR(20) CHECK (content_type IN ('video','reading','quiz','interactive')),
    content_url VARCHAR(500),
    duration_minutes INT,
    quiz_id UUID
);

CREATE TABLE quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255),
    questions JSONB NOT NULL
);

CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    progress_percent INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('enrolled','in_progress','completed','dropped')),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    total_time_spent INT DEFAULT 0
);

CREATE TABLE quiz_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enrollment_id UUID REFERENCES enrollments(id),
    module_id UUID REFERENCES modules(id),
    score_percent INT,
    answers JSONB,
    passed BOOLEAN DEFAULT FALSE,
    attempted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    course_id UUID REFERENCES courses(id),
    enrollment_id UUID REFERENCES enrollments(id),
    certificate_number VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    course_name VARCHAR(255),
    issued_date DATE,
    expiry_date DATE,
    validation_hash VARCHAR(255),
    blockchain_tx_hash VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','expired','revoked')),
    pdf_url VARCHAR(500),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LMS Resource Library
CREATE TABLE lms_resources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    type VARCHAR(30) CHECK (type IN ('legal_doc','checklist','template','guide','video','audio','pdf')),
    description TEXT,
    file_url VARCHAR(500),
    file_size VARCHAR(20),
    download_count INT DEFAULT 0,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Discussions
CREATE TABLE discussions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    category VARCHAR(50),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    tags JSONB DEFAULT '[]',
    views_count INT DEFAULT 0,
    replies_count INT DEFAULT 0,
    is_pinned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE support_tickets (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    priority VARCHAR(50) DEFAULT 'medium',
    status VARCHAR(50) DEFAULT 'open',
    description TEXT,
    reporter VARCHAR(100),
    reporter_role VARCHAR(50),
    reporter_detail VARCHAR(255),
    reporter_avatar VARCHAR(500),
    assigned_to VARCHAR(100),
    attachment VARCHAR(255),
    attachment_size VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolution_notes TEXT
);

CREATE TABLE support_ticket_updates (
    id SERIAL PRIMARY KEY,
    ticket_id INT REFERENCES support_tickets(id) ON DELETE CASCADE,
    user_name VARCHAR(100),
    action VARCHAR(50),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE discussion_replies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    discussion_id UUID REFERENCES discussions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    parent_id UUID REFERENCES discussion_replies(id),
    content TEXT,
    upvotes INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('payment','maintenance','lease','course','system','fraud_alert')),
    title VARCHAR(255),
    message TEXT,
    action_url VARCHAR(500),
    action_type VARCHAR(20) CHECK (action_type IN ('navigate','download','enroll','approve')),
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low','normal','high','urgent')),
    channels JSONB DEFAULT '["in_app"]',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit Logs (Immutable)
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    user_role VARCHAR(20),
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- System Health
CREATE TABLE system_health (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metric_name VARCHAR(100),
    metric_value VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('clean','warning','critical')),
    region_id UUID REFERENCES regions(id),
    checked_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scheduled Tasks
CREATE TABLE scheduled_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_type VARCHAR(50),
    cron_expression VARCHAR(100),
    last_run_at TIMESTAMPTZ,
    next_run_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    payload JSONB
);

-- Export Jobs
CREATE TABLE export_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    job_type VARCHAR(20) CHECK (job_type IN ('pdf','csv','excel','certificate_pdf')),
    entity_type VARCHAR(50),
    query_params JSONB,
    status VARCHAR(20) DEFAULT 'queued' CHECK (status IN ('queued','processing','completed','failed')),
    file_url VARCHAR(500),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_kyc ON users(kyc_status);
CREATE INDEX idx_users_fraud ON users(fraud_score) WHERE fraud_score > 0;
CREATE INDEX idx_properties_landlord ON properties(landlord_id);
-- CREATE INDEX idx_properties_location ON properties USING GIST(location);
CREATE INDEX idx_properties_region ON properties(region_id);
CREATE INDEX idx_units_property ON units(property_id);
CREATE INDEX idx_leases_tenant ON leases(tenant_id);
CREATE INDEX idx_leases_status ON leases(status);
CREATE INDEX idx_leases_end_date ON leases(end_date);
CREATE INDEX idx_rent_payments_due ON rent_payments(due_date);
CREATE INDEX idx_rent_payments_status ON rent_payments(status);
CREATE INDEX idx_work_orders_status ON work_orders(status);
CREATE INDEX idx_work_orders_vendor ON work_orders(assigned_vendor_id);
CREATE INDEX idx_bids_work_order ON bids(work_order_id);
CREATE INDEX idx_messages_room ON messages(room_id, created_at);
CREATE INDEX idx_audit_user ON audit_logs(user_id, created_at);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at);

-- Materialized Views (Admin Dashboard)
CREATE MATERIALIZED VIEW mv_operational_overview AS
SELECT
    COUNT(*) FILTER (WHERE role = 'tenant') as total_users,
    COUNT(*) FILTER (WHERE role = 'vendor') as active_vendors,
    (SELECT COUNT(*) FROM properties WHERE status = 'active') as total_properties
FROM user_roles;

CREATE MATERIALIZED VIEW mv_rent_status AS
SELECT
    rp.property_id,
    p.landlord_id,
    COUNT(*) FILTER (WHERE rp.status = 'paid') * 100.0 / NULLIF(COUNT(*), 0) as pct_paid,
    COUNT(*) FILTER (WHERE rp.status = 'partial') * 100.0 / NULLIF(COUNT(*), 0) as pct_partial,
    COUNT(*) FILTER (WHERE rp.status = 'late') * 100.0 / NULLIF(COUNT(*), 0) as pct_late,
    COUNT(*) as total_records
FROM rent_payments rp
JOIN properties p ON rp.property_id = p.id
WHERE rp.due_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY rp.property_id, p.landlord_id;

-- Triggers
CREATE OR REPLACE FUNCTION normalize_display_name()
RETURNS TRIGGER AS $$
BEGIN
    NEW.display_name = INITCAP(TRIM(NEW.display_name));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_normalize_name BEFORE INSERT OR UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION normalize_display_name();

CREATE OR REPLACE FUNCTION auto_reject_other_bids()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'accepted' THEN
        UPDATE bids SET status = 'rejected'
        WHERE work_order_id = NEW.work_order_id AND id != NEW.id AND status = 'pending';

        UPDATE work_orders SET
            assigned_vendor_id = NEW.vendor_id,
            status = 'scheduled',
            scheduled_date = NEW.proposed_date
        WHERE id = NEW.work_order_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bid_acceptance AFTER UPDATE ON bids
FOR EACH ROW WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION auto_reject_other_bids();
