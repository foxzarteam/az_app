# Leads API 404 Error - Troubleshooting Guide

## Problem
POST `/api/leads` endpoint returning 404 error even after deployment.

## Step-by-Step Fix

### 1. Verify Code is Committed and Pushed
```bash
cd server
git status
git add .
git commit -m "Add leads API endpoints"
git push origin main
```

### 2. Check Vercel Deployment
1. Go to Vercel Dashboard
2. Select your project
3. Check **Deployments** tab
4. Verify latest deployment is **Ready** (green checkmark)
5. Check **Build Logs** for any errors

### 3. Verify Vercel Project Settings
- **Root Directory**: Must be `server` (not root)
- **Framework Preset**: `Other`
- **Build Command**: `npm run build` (optional)
- **Output Directory**: `dist` (optional)

### 4. Check Environment Variables
Vercel Dashboard → Settings → Environment Variables:
```
SUPABASE_URL=your-supabase-url
SUPABASE_SERVICE_KEY=your-service-key
API_PREFIX=api
NODE_ENV=production
```

### 5. Verify File Structure
Ensure these files exist:
```
server/
├── api/
│   └── index.ts          ✅ Must exist
├── src/
│   ├── app.module.ts    ✅ Must import LeadsModule
│   └── leads/
│       ├── leads.module.ts
│       ├── leads.controller.ts
│       └── leads.service.ts
└── vercel.json          ✅ Must exist
```

### 6. Test Endpoints

**Test GET (should work):**
```
https://az-project.vercel.app/api/leads
```
Expected: JSON with API info

**Test POST (use Postman/Thunder Client):**
```
POST https://az-project.vercel.app/api/leads
Content-Type: application/json

{
  "pan": "ABCDE1234F",
  "mobileNumber": "9876543210",
  "fullName": "Test User",
  "category": "personal_loan"
}
```

### 7. Check Vercel Function Logs
1. Vercel Dashboard → Project → Functions
2. Click on `/api/index.ts`
3. Check **Logs** tab for errors

### 8. Force Redeploy
1. Vercel Dashboard → Deployments
2. Click on latest deployment
3. Click **Redeploy** button
4. Wait for deployment to complete

### 9. Clear Cache and Test
- Clear browser cache
- Use incognito/private window
- Test with Postman/Thunder Client (not browser)

## Common Issues

### Issue 1: Root Directory Wrong
**Symptom**: 404 on all endpoints
**Fix**: Vercel Settings → Root Directory = `server`

### Issue 2: Module Not Imported
**Symptom**: 404 on `/api/leads` but other endpoints work
**Fix**: Check `src/app.module.ts` has `LeadsModule` in imports

### Issue 3: Build Error
**Symptom**: Deployment fails
**Fix**: Check Build Logs in Vercel Dashboard

### Issue 4: Caching Issue
**Symptom**: Old code still running
**Fix**: Force redeploy or wait 2-3 minutes

## Verification Checklist

- [ ] Code committed and pushed to git
- [ ] Vercel deployment successful (green checkmark)
- [ ] Root Directory set to `server`
- [ ] Environment variables set correctly
- [ ] `api/index.ts` file exists
- [ ] `src/app.module.ts` imports `LeadsModule`
- [ ] GET `/api/leads` returns JSON (not 404)
- [ ] POST `/api/leads` tested with Postman

## Still Not Working?

1. **Check Vercel Function Logs**:
   - Dashboard → Functions → `/api/index.ts` → Logs
   - Look for error messages

2. **Test Locally**:
   ```bash
   cd server
   npm install
   npm run start:dev
   # Test: http://localhost:3000/api/leads
   ```

3. **Verify Database**:
   - Supabase Dashboard → Table Editor
   - Check `leads` table exists
   - Verify RLS policies allow inserts

4. **Contact Support**:
   - Share Vercel deployment logs
   - Share error messages from Flutter app
   - Share network request details
