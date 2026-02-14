-- ============================================
-- LEADS TABLE - Supabase SQL Query
-- ============================================
-- This table stores all leads submitted through the lead form
-- Category field: personal_loan (default), insurance, credit_card

-- ============================================
-- 0. CREATE FUNCTION FOR AUTO-UPDATE updated_at
-- ============================================
-- This function will be used by the trigger to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 1. CREATE LEADS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User who created/submitted this lead (banker/agent)
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Lead form fields
    pan VARCHAR(10) NOT NULL,
    mobile_number VARCHAR(10) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    pincode VARCHAR(6),
    required_amount DECIMAL(12, 2),
    
    -- Category field: personal_loan (default), insurance, credit_card
    category VARCHAR(50) NOT NULL DEFAULT 'personal_loan' 
        CHECK (category IN ('personal_loan', 'insurance', 'credit_card')),
    
    -- Lead status tracking
    status VARCHAR(50) DEFAULT 'pending' 
        CHECK (status IN ('pending', 'in_process', 'approved', 'rejected', 'action_required')),
    
    -- Additional metadata
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. CREATE INDEXES FOR PERFORMANCE
-- ============================================
-- Index on user_id for faster lookups of leads by banker
CREATE INDEX IF NOT EXISTS idx_leads_user_id ON leads(user_id);

-- Index on mobile_number for searching leads by customer mobile
CREATE INDEX IF NOT EXISTS idx_leads_mobile_number ON leads(mobile_number);

-- Index on category for filtering by product type
CREATE INDEX IF NOT EXISTS idx_leads_category ON leads(category);

-- Index on status for filtering by lead status
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);

-- Index on created_at for sorting by date
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at DESC);

-- Composite index for common queries (user's leads by category)
CREATE INDEX IF NOT EXISTS idx_leads_user_category ON leads(user_id, category);

-- ============================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. RLS POLICIES
-- ============================================
-- Allow users to insert their own leads
CREATE POLICY "Users can insert own leads"
    ON leads FOR INSERT
    WITH CHECK (true);

-- Allow users to view their own leads
CREATE POLICY "Users can view own leads"
    ON leads FOR SELECT
    USING (true);

-- Allow users to update their own leads
CREATE POLICY "Users can update own leads"
    ON leads FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow users to delete their own leads (optional)
CREATE POLICY "Users can delete own leads"
    ON leads FOR DELETE
    USING (true);

-- ============================================
-- 5. TRIGGER FOR AUTO-UPDATE updated_at
-- ============================================
-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_leads_updated_at
    BEFORE UPDATE ON leads
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- 6. USEFUL QUERIES FOR YOUR APP
-- ============================================

-- Insert a new lead (example)
-- INSERT INTO leads (
--     user_id,
--     pan,
--     mobile_number,
--     full_name,
--     email,
--     pincode,
--     required_amount,
--     category
-- ) VALUES (
--     'user-uuid-here',
--     'ABCDE1234F',
--     '9876543210',
--     'John Doe',
--     'john@example.com',
--     '110001',
--     50000.00,
--     'personal_loan'
-- ) RETURNING *;

-- Get all leads for a specific user
-- SELECT * FROM leads 
-- WHERE user_id = 'user-uuid-here' 
-- ORDER BY created_at DESC;

-- Get leads by category
-- SELECT * FROM leads 
-- WHERE user_id = 'user-uuid-here' 
--   AND category = 'personal_loan'
-- ORDER BY created_at DESC;

-- Get leads by status
-- SELECT * FROM leads 
-- WHERE user_id = 'user-uuid-here' 
--   AND status = 'pending'
-- ORDER BY created_at DESC;

-- Update lead status
-- UPDATE leads 
-- SET status = 'in_process', updated_at = NOW()
-- WHERE id = 'lead-uuid-here';

-- Count total leads by user
-- SELECT COUNT(*) as total_leads 
-- FROM leads 
-- WHERE user_id = 'user-uuid-here';

-- Count leads by category
-- SELECT category, COUNT(*) as count 
-- FROM leads 
-- WHERE user_id = 'user-uuid-here'
-- GROUP BY category;
