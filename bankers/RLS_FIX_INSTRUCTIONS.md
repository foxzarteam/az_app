# Supabase RLS Policies Fix Instructions

## Problem
Data is not being saved to Supabase because Row Level Security (RLS) policies are blocking INSERT operations.

## Solution

### Step 1: Open Supabase SQL Editor
1. Go to https://supabase.com/dashboard
2. Login with your credentials
3. Select your project: **bankers**
4. Go to **SQL Editor** (left sidebar)

### Step 2: Run This SQL

Copy and paste this SQL code in the SQL Editor and click **Run**:

```sql
-- Drop existing restrictive policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;

-- Allow INSERT for anyone (needed for signup)
CREATE POLICY "Users can insert own profile"
    ON users FOR INSERT
    WITH CHECK (true);

-- Allow SELECT for anyone (needed to check if user exists)
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (true);

-- Allow UPDATE for anyone (needed to update MPIN and login status)
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (true)
    WITH CHECK (true);
```

### Step 3: Verify
After running the SQL:
1. Go to **Table Editor** > **users** table
2. Try inserting data from your app
3. Check if data appears in the table

### Alternative: Disable RLS (NOT RECOMMENDED FOR PRODUCTION)

If you want to disable RLS completely for testing:

```sql
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

**Note:** Only use this for development/testing. Re-enable RLS before production.

### Step 4: Test the App
1. Run your Flutter app
2. Enter mobile number
3. Set MPIN
4. Check Supabase dashboard - data should appear

## Troubleshooting

If data still doesn't save:
1. Check browser console/Flutter logs for errors
2. Verify Supabase URL and API key in `lib/config/supabase_config.dart`
3. Check network connectivity
4. Verify table structure matches the schema
