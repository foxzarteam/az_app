-- ============================================
-- Payment Accounts Table (Supabase) – UPI & Bank in same table
-- Run this in Supabase Dashboard → SQL Editor
-- ============================================
-- Prerequisite: users table must exist with id UUID.

-- 1. Create table: one row per user per type ('upi' or 'bank')
CREATE TABLE IF NOT EXISTS payment_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    payment_type VARCHAR(10) NOT NULL CHECK (payment_type IN ('upi', 'bank')),
    -- UPI: UPI ID or mobile number (bank columns NULL)
    upi_id VARCHAR(255),
    -- Bank: bank name & IFSC only (upi_id NULL)
    bank_name VARCHAR(255),
    ifsc_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, payment_type)
);

-- 2. Indexes for fast lookup by user
CREATE INDEX IF NOT EXISTS idx_payment_accounts_user_id ON payment_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_accounts_user_type ON payment_accounts(user_id, payment_type);

-- 3. RLS
ALTER TABLE payment_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all on payment_accounts"
    ON payment_accounts FOR ALL
    USING (true)
    WITH CHECK (true);

-- 4. Auto-update updated_at (use existing function if you have it, else create)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_payment_accounts_updated_at ON payment_accounts;
CREATE TRIGGER update_payment_accounts_updated_at
    BEFORE UPDATE ON payment_accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Example queries (for reference, do not run as-is)
-- ============================================
-- Get all payment details for a user:
--   SELECT * FROM payment_accounts WHERE user_id = 'your-user-uuid' ORDER BY payment_type;

-- Save/update UPI:
--   INSERT INTO payment_accounts (user_id, payment_type, upi_id)
--   VALUES ('your-user-uuid', 'upi', 'name@upi')
--   ON CONFLICT (user_id, payment_type) DO UPDATE SET upi_id = EXCLUDED.upi_id, updated_at = NOW()
--   RETURNING *;

-- Save/update Bank (only bank_name & ifsc_code):
--   INSERT INTO payment_accounts (user_id, payment_type, bank_name, ifsc_code)
--   VALUES ('your-user-uuid', 'bank', 'State Bank of India', 'SBIN0001234')
--   ON CONFLICT (user_id, payment_type) DO UPDATE SET bank_name = EXCLUDED.bank_name, ifsc_code = EXCLUDED.ifsc_code, updated_at = NOW()
--   RETURNING *;
