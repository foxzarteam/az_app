-- ============================================
-- BankBridge App - Supabase Database Schema
-- ============================================

-- Enable UUID extension (Supabase has this by default)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE
-- ============================================
-- Main user table to store user information
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mobile_number VARCHAR(10) UNIQUE NOT NULL,
    user_name VARCHAR(255),
    email VARCHAR(255),
    mpin VARCHAR(4), -- 4-digit MPIN (consider hashing this!)
    is_active BOOLEAN DEFAULT true,
    is_logged_in BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Create index on mobile_number for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_mobile_number ON users(mobile_number);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ============================================
-- 2. OTP SESSIONS TABLE
-- ============================================
-- Temporary OTP storage for verification
CREATE TABLE IF NOT EXISTS otp_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mobile_number VARCHAR(10) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP WITH TIME ZONE,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on mobile_number and expires_at
CREATE INDEX IF NOT EXISTS idx_otp_mobile_number ON otp_sessions(mobile_number);
CREATE INDEX IF NOT EXISTS idx_otp_expires_at ON otp_sessions(expires_at);

-- ============================================
-- 3. USER SESSIONS TABLE (Optional)
-- ============================================
-- Track user login sessions
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_info TEXT,
    ip_address VARCHAR(45),
    login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    logout_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

-- Create index on user_id
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);

-- ============================================
-- 4. PAYMENT ACCOUNTS TABLE (UPI & Bank in same table)
-- ============================================
-- One row per user per type: payment_type = 'upi' OR 'bank'
-- UPI: store in upi_id (UPI ID or mobile number). bank_name, ifsc_code NULL.
-- Bank: store in bank_name, ifsc_code. upi_id NULL.
CREATE TABLE IF NOT EXISTS payment_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    payment_type VARCHAR(10) NOT NULL CHECK (payment_type IN ('upi', 'bank')),
    -- UPI: UPI ID or mobile number
    upi_id VARCHAR(255),
    -- Bank: bank name and IFSC only (as per app form)
    bank_name VARCHAR(255),
    ifsc_code VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, payment_type)
);

CREATE INDEX IF NOT EXISTS idx_payment_accounts_user_id ON payment_accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_accounts_user_type ON payment_accounts(user_id, payment_type);

-- ============================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE otp_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_accounts ENABLE ROW LEVEL SECURITY;

-- Allow INSERT for signup (anyone can create account)
CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    WITH CHECK (true);

-- Allow SELECT to check if user exists
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (true);

-- Allow UPDATE to update MPIN and login status
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- OTP sessions can be accessed by mobile number
CREATE POLICY "Users can manage own OTP sessions"
    ON otp_sessions FOR ALL
    USING (mobile_number = current_setting('app.current_mobile', true));

-- User sessions can be accessed by user
CREATE POLICY "Users can view own sessions"
    ON user_sessions FOR SELECT
    USING (user_id::text = auth.uid()::text);

-- Payment accounts: app manages by user_id (same as users table)
CREATE POLICY "Allow all on payment_accounts"
    ON payment_accounts FOR ALL
    USING (true)
    WITH CHECK (true);

-- ============================================
-- 6. FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for payment_accounts
CREATE TRIGGER update_payment_accounts_updated_at
    BEFORE UPDATE ON payment_accounts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to clean expired OTPs (run periodically)
CREATE OR REPLACE FUNCTION clean_expired_otps()
RETURNS void AS $$
BEGIN
    DELETE FROM otp_sessions
    WHERE expires_at < NOW() OR is_verified = true;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 7. USEFUL QUERIES FOR YOUR APP
-- ============================================

-- Check if user exists by mobile number
-- SELECT * FROM users WHERE mobile_number = '9876543210';

-- Get user by mobile number
-- SELECT id, user_name, email, mobile_number, created_at 
-- FROM users WHERE mobile_number = '9876543210';

-- Verify OTP
-- SELECT * FROM otp_sessions 
-- WHERE mobile_number = '9876543210' 
--   AND otp_code = '1234' 
--   AND expires_at > NOW() 
--   AND is_verified = false
--   AND attempts < max_attempts;

-- Mark OTP as verified
-- UPDATE otp_sessions 
-- SET is_verified = true, verified_at = NOW() 
-- WHERE id = 'otp_session_id';

-- Create new user
-- INSERT INTO users (mobile_number, user_name, email) 
-- VALUES ('9876543210', 'John Doe', 'john@example.com')
-- RETURNING *;

-- Update user MPIN
-- UPDATE users 
-- SET mpin = '1234', updated_at = NOW() 
-- WHERE mobile_number = '9876543210';

-- Get user login status
-- SELECT is_logged_in, last_login_at FROM users 
-- WHERE mobile_number = '9876543210';

-- Clean expired OTPs (run this periodically via cron job)
-- SELECT clean_expired_otps();

-- ============================================
-- PAYMENT ACCOUNTS QUERIES
-- ============================================
-- Get payment details for a user
-- SELECT * FROM payment_accounts WHERE user_id = 'user_uuid' ORDER BY payment_type;

-- Upsert UPI (insert or update)
-- INSERT INTO payment_accounts (user_id, payment_type, upi_id)
-- VALUES ('user_uuid', 'upi', 'name@upi')
-- ON CONFLICT (user_id, payment_type) DO UPDATE SET upi_id = EXCLUDED.upi_id, updated_at = NOW()
-- RETURNING *;

-- Upsert Bank (insert or update)
-- INSERT INTO payment_accounts (user_id, payment_type, bank_name, ifsc_code)
-- VALUES ('user_uuid', 'bank', 'State Bank of India', 'SBIN0001234')
-- ON CONFLICT (user_id, payment_type) DO UPDATE SET bank_name = EXCLUDED.bank_name, ifsc_code = EXCLUDED.ifsc_code, updated_at = NOW()
-- RETURNING *;
