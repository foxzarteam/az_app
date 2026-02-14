# Complete Secure Database Setup Guide

## Overview
This guide provides step-by-step instructions to set up a secure database schema with enhanced Row Level Security (RLS) policies for the BankBridge app.

## Security Features

### 1. **Row Level Security (RLS)**
- All tables have RLS enabled
- Policies restrict access based on mobile number
- Prevents unauthorized data access

### 2. **Data Validation**
- Mobile number format validation (Indian numbers: 6-9 followed by 9 digits)
- MPIN format validation (exactly 4 digits)
- OTP format validation (exactly 4 digits)

### 3. **Constraints**
- Check constraints ensure data integrity
- Unique constraints prevent duplicate mobile numbers
- Not null constraints on required fields

### 4. **Helper Functions**
- Secure functions for common operations
- MPIN verification function
- User lookup function

## Setup Instructions

### Step 1: Open Supabase SQL Editor
1. Go to https://supabase.com/dashboard
2. Login with your credentials
3. Select project: **bankers**
4. Click on **SQL Editor** in the left sidebar
5. Click **New Query**

### Step 2: Run the Complete Schema
1. Open the file `complete_secure_schema.sql`
2. Copy the entire contents
3. Paste into Supabase SQL Editor
4. Click **Run** (or press Ctrl+Enter)

### Step 3: Verify Setup
After running the SQL, verify:

1. **Check Tables Created:**
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public';
   ```
   Should show: `users`, `otp_sessions`, `user_sessions`

2. **Check RLS Enabled:**
   ```sql
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE schemaname = 'public';
   ```
   All tables should show `rowsecurity = true`

3. **Check Policies:**
   ```sql
   SELECT schemaname, tablename, policyname 
   FROM pg_policies 
   WHERE schemaname = 'public';
   ```
   Should show multiple policies for each table

### Step 4: Test Insert
Test if you can insert a user:

```sql
INSERT INTO users (mobile_number, user_name) 
VALUES ('9876543210', 'Test User')
RETURNING *;
```

If successful, you should see the new user record.

### Step 5: Test Your App
1. Run your Flutter app
2. Enter mobile number: `9876543210`
3. Set MPIN: `1234`
4. Check Supabase dashboard - data should appear

## Security Policies Explained

### Users Table Policies

1. **Public can insert new users**
   - Allows signup
   - Validates mobile number format
   - Ensures user_name is provided

2. **Users can view by mobile**
   - Allows checking if user exists
   - Used for login verification

3. **Users can update by mobile**
   - Allows updating MPIN and login status
   - Prevents mobile number changes
   - Validates MPIN format

### OTP Sessions Policies

1. **Public can create OTP**
   - Allows OTP generation
   - Validates mobile and OTP format

2. **Users can view own OTP**
   - Allows OTP verification
   - Used during login process

3. **Users can update own OTP**
   - Allows marking OTP as verified
   - Tracks verification attempts

### User Sessions Policies

- Users can view, create, and update their own sessions
- Tracks login/logout events

## Production Recommendations

### 1. **MPIN Hashing**
Currently, MPINs are stored in plain text. For production:

```sql
-- Use bcrypt or similar
-- Update the hash_mpin function to use proper hashing
-- Store hashed MPIN instead of plain text
```

### 2. **Rate Limiting**
Add rate limiting for:
- OTP generation (max 3 per hour per mobile)
- Login attempts (max 5 failed attempts per hour)
- MPIN attempts (max 3 failed attempts per hour)

### 3. **Audit Logging**
Create an audit log table to track:
- All login attempts
- MPIN changes
- Profile updates

### 4. **Encryption**
- Encrypt sensitive data at rest
- Use HTTPS for all API calls
- Encrypt MPIN in transit

### 5. **Backup & Recovery**
- Set up automated backups
- Test recovery procedures
- Monitor database performance

## Troubleshooting

### Issue: Cannot insert users
**Solution:** Check RLS policies are correctly set up. Run:
```sql
SELECT * FROM pg_policies WHERE tablename = 'users';
```

### Issue: Cannot update MPIN
**Solution:** Verify UPDATE policy exists:
```sql
SELECT policyname FROM pg_policies 
WHERE tablename = 'users' AND cmd = 'UPDATE';
```

### Issue: Data not appearing
**Solution:** 
1. Check browser console for errors
2. Verify Supabase URL and API key
3. Check network connectivity
4. Review RLS policies

### Issue: Mobile number validation fails
**Solution:** Ensure mobile number follows format: `[6-9][0-9]{9}` (10 digits starting with 6-9)

## Maintenance

### Daily
- Monitor failed login attempts
- Check for expired OTPs

### Weekly
- Clean expired OTPs: `SELECT clean_expired_otps();`
- Review user activity

### Monthly
- Clean old sessions: `SELECT clean_old_sessions();`
- Review and update security policies
- Check for suspicious activity

## Support

If you encounter issues:
1. Check Supabase logs
2. Review Flutter console logs
3. Verify RLS policies
4. Test with SQL queries directly

## Next Steps

After setup:
1. Test all app flows
2. Monitor database performance
3. Set up alerts for errors
4. Plan for production deployment
