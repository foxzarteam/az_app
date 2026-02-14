-- Fix RLS Policies to Allow Inserts
-- Run this in Supabase SQL Editor

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;

-- Allow anyone to insert (for signup)
CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    WITH CHECK (true);

-- Allow anyone to view (for checking if user exists)
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (true);

-- Allow anyone to update by mobile number
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (true)
    WITH CHECK (true);
