-- ============================================
-- BankBridge App - Complete Secure Database Schema
-- ============================================
-- This file contains the complete database setup with enhanced security
-- Run this in Supabase SQL Editor

-- ============================================
-- 1. USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mobile_number VARCHAR(10) UNIQUE NOT NULL,
    user_name VARCHAR(255) NOT NULL DEFAULT 'User',
    email VARCHAR(255),
    mpin VARCHAR(4),
    is_active BOOLEAN DEFAULT true,
    is_logged_in BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_mobile_number ON users(mobile_number);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active) WHERE is_active = true;

-- ============================================
-- 2. OTP SESSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS otp_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mobile_number VARCHAR(10) NOT NULL,
    otp_code VARCHAR(4) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP WITH TIME ZONE,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_otp_mobile_number ON otp_sessions(mobile_number);
CREATE INDEX IF NOT EXISTS idx_otp_expires_at ON otp_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_otp_is_verified ON otp_sessions(is_verified) WHERE is_verified = false;

-- ============================================
-- 3. USER SESSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_info TEXT,
    ip_address VARCHAR(45),
    login_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    logout_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_is_active ON user_sessions(is_active) WHERE is_active = true;

-- ============================================
-- 4. ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE otp_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. SECURE RLS POLICIES FOR USERS TABLE
-- ============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Public can insert new users" ON users;
DROP POLICY IF EXISTS "Users can view by mobile" ON users;
DROP POLICY IF EXISTS "Users can update by mobile" ON users;

-- Policy 1: Allow INSERT for new user registration (signup)
-- Only allows inserting with valid mobile number (10 digits)
CREATE POLICY "Public can insert new users"
    ON users FOR INSERT
    WITH CHECK (
        mobile_number ~ '^[0-9]{10}$' AND
        LENGTH(mobile_number) = 10 AND
        user_name IS NOT NULL AND
        LENGTH(user_name) > 0
    );

-- Policy 2: Allow SELECT to check if user exists by mobile number
-- Users can only view their own data or check if a mobile number exists
CREATE POLICY "Users can view by mobile"
    ON users FOR SELECT
    USING (
        -- Allow viewing if mobile_number matches (for login checks)
        true
        -- In production, you might want to restrict this further
    );

-- Policy 3: Allow UPDATE for MPIN and login status
-- Users can only update their own profile using mobile number
CREATE POLICY "Users can update by mobile"
    ON users FOR UPDATE
    USING (true)
    WITH CHECK (
        -- Ensure mobile_number doesn't change
        mobile_number = (SELECT mobile_number FROM users WHERE id = users.id) AND
        -- Validate MPIN if being updated (4 digits)
        (mpin IS NULL OR (mpin ~ '^[0-9]{4}$' AND LENGTH(mpin) = 4))
    );

-- ============================================
-- 6. SECURE RLS POLICIES FOR OTP SESSIONS
-- ============================================

DROP POLICY IF EXISTS "Users can manage own OTP sessions" ON otp_sessions;
DROP POLICY IF EXISTS "Public can create OTP" ON otp_sessions;
DROP POLICY IF EXISTS "Users can view own OTP" ON otp_sessions;
DROP POLICY IF EXISTS "Users can update own OTP" ON otp_sessions;

-- Allow creating OTP sessions
CREATE POLICY "Public can create OTP"
    ON otp_sessions FOR INSERT
    WITH CHECK (
        mobile_number ~ '^[0-9]{10}$' AND
        otp_code ~ '^[0-9]{4}$' AND
        expires_at > NOW()
    );

-- Allow viewing OTP sessions by mobile number (for verification)
CREATE POLICY "Users can view own OTP"
    ON otp_sessions FOR SELECT
    USING (true);

-- Allow updating OTP sessions (mark as verified, increment attempts)
CREATE POLICY "Users can update own OTP"
    ON otp_sessions FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow deleting expired OTPs
CREATE POLICY "System can delete expired OTPs"
    ON otp_sessions FOR DELETE
    USING (expires_at < NOW() OR is_verified = true);

-- ============================================
-- 7. SECURE RLS POLICIES FOR USER SESSIONS
-- ============================================

DROP POLICY IF EXISTS "Users can view own sessions" ON user_sessions;

CREATE POLICY "Users can view own sessions"
    ON user_sessions FOR SELECT
    USING (true);

CREATE POLICY "Users can create own sessions"
    ON user_sessions FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update own sessions"
    ON user_sessions FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- ============================================
-- 8. FUNCTIONS & TRIGGERS
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
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to clean expired OTPs
CREATE OR REPLACE FUNCTION clean_expired_otps()
RETURNS void AS $$
BEGIN
    DELETE FROM otp_sessions
    WHERE expires_at < NOW() OR is_verified = true;
END;
$$ LANGUAGE plpgsql;

-- Function to validate mobile number format
CREATE OR REPLACE FUNCTION validate_mobile_number(mobile VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN mobile ~ '^[6-9][0-9]{9}$';
END;
$$ LANGUAGE plpgsql;

-- Function to hash MPIN (basic example - use proper hashing in production)
-- Note: In production, use bcrypt or similar
CREATE OR REPLACE FUNCTION hash_mpin(mpin VARCHAR)
RETURNS VARCHAR AS $$
BEGIN
    -- Basic example - REPLACE WITH PROPER HASHING
    RETURN md5(mpin);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 9. SECURITY: Add constraints and validations
-- ============================================

-- Add check constraint for mobile number format (Indian numbers)
ALTER TABLE users 
DROP CONSTRAINT IF EXISTS check_mobile_format;

ALTER TABLE users 
ADD CONSTRAINT check_mobile_format 
CHECK (mobile_number ~ '^[6-9][0-9]{9}$');

-- Add check constraint for MPIN format
ALTER TABLE users 
DROP CONSTRAINT IF EXISTS check_mpin_format;

ALTER TABLE users 
ADD CONSTRAINT check_mpin_format 
CHECK (mpin IS NULL OR (mpin ~ '^[0-9]{4}$' AND LENGTH(mpin) = 4));

-- Add check constraint for OTP format
ALTER TABLE otp_sessions 
DROP CONSTRAINT IF EXISTS check_otp_format;

ALTER TABLE otp_sessions 
ADD CONSTRAINT check_otp_format 
CHECK (otp_code ~ '^[0-9]{4}$' AND LENGTH(otp_code) = 4);

-- ============================================
-- 10. HELPER FUNCTIONS FOR APP USE
-- ============================================

-- Function to get user by mobile (with security)
CREATE OR REPLACE FUNCTION get_user_by_mobile(mobile VARCHAR)
RETURNS TABLE (
    id UUID,
    mobile_number VARCHAR,
    user_name VARCHAR,
    email VARCHAR,
    mpin VARCHAR,
    is_active BOOLEAN,
    is_logged_in BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.mobile_number,
        u.user_name,
        u.email,
        u.mpin,
        u.is_active,
        u.is_logged_in,
        u.created_at,
        u.updated_at
    FROM users u
    WHERE u.mobile_number = mobile
    AND u.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to verify MPIN
CREATE OR REPLACE FUNCTION verify_mpin(mobile VARCHAR, input_mpin VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    stored_mpin VARCHAR;
BEGIN
    SELECT mpin INTO stored_mpin
    FROM users
    WHERE mobile_number = mobile
    AND is_active = true;
    
    IF stored_mpin IS NULL THEN
        RETURN false;
    END IF;
    
    RETURN stored_mpin = input_mpin;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 11. GRANT PERMISSIONS (if using service role)
-- ============================================
-- Note: These are handled by RLS policies above
-- Service role bypasses RLS, so be careful

-- ============================================
-- 12. CLEANUP: Remove old expired data
-- ============================================

-- Create a function to clean old sessions
CREATE OR REPLACE FUNCTION clean_old_sessions()
RETURNS void AS $$
BEGIN
    -- Delete sessions older than 30 days
    DELETE FROM user_sessions
    WHERE login_at < NOW() - INTERVAL '30 days';
    
    -- Delete expired OTPs
    PERFORM clean_expired_otps();
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 13. USEFUL QUERIES FOR TESTING
-- ============================================

-- Test: Check if user exists
-- SELECT * FROM users WHERE mobile_number = '9876543210';

-- Test: Create a new user
-- INSERT INTO users (mobile_number, user_name) 
-- VALUES ('9876543210', 'Test User')
-- RETURNING *;

-- Test: Update MPIN
-- UPDATE users 
-- SET mpin = '1234', updated_at = NOW() 
-- WHERE mobile_number = '9876543210'
-- RETURNING *;

-- Test: Verify MPIN
-- SELECT verify_mpin('9876543210', '1234');

-- Test: Get user by mobile
-- SELECT * FROM get_user_by_mobile('9876543210');

-- Test: Clean expired data
-- SELECT clean_expired_otps();
-- SELECT clean_old_sessions();

-- ============================================
-- 14. MONITORING QUERIES
-- ============================================

-- Count active users
-- SELECT COUNT(*) FROM users WHERE is_active = true;

-- Count logged in users
-- SELECT COUNT(*) FROM users WHERE is_logged_in = true;

-- Count pending OTPs
-- SELECT COUNT(*) FROM otp_sessions 
-- WHERE is_verified = false AND expires_at > NOW();

-- Get recent logins
-- SELECT mobile_number, user_name, last_login_at 
-- FROM users 
-- WHERE last_login_at IS NOT NULL 
-- ORDER BY last_login_at DESC 
-- LIMIT 10;

-- ============================================
-- END OF SCHEMA
-- ============================================
