# Security Configuration Guide

## CORS Security

### Development Mode
- **CORS**: Allows all origins (`*`)
- **Credentials**: Disabled
- **Use Case**: Local development only

### Production Mode
- **CORS**: Only allows specific origins from `ALLOWED_ORIGINS` environment variable
- **Credentials**: Enabled only when specific origins are configured
- **Use Case**: Production deployment

## Environment Variables

### Required for Production

```env
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com,https://app.yourdomain.com
```

### Development (Optional)
```env
NODE_ENV=development
# ALLOWED_ORIGINS not required - allows all origins
```

## Security Best Practices

1. **Always set `ALLOWED_ORIGINS` in production**
   - List only your trusted domains
   - Include both `www` and non-`www` versions if needed
   - Include mobile app domains if using web views

2. **Never use `*` in production**
   - Current code automatically restricts to specific origins in production
   - If `ALLOWED_ORIGINS` is not set in production, CORS will be disabled (empty array)

3. **Static Images Security**
   - Images are served with same CORS rules as API
   - Production: Only allowed origins can access images
   - Development: All origins can access (for testing)

4. **Credentials**
   - Only enabled when specific origins are configured
   - Prevents unauthorized cookie/header access

## Vercel Deployment

Set these environment variables in Vercel Dashboard:

```
NODE_ENV=production
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
SUPABASE_URL=your-supabase-url
SUPABASE_SERVICE_KEY=your-service-key
```

## Testing

### Development
```bash
# No ALLOWED_ORIGINS needed
npm run start:dev
# CORS allows all origins
```

### Production Test
```bash
# Set environment variables
export NODE_ENV=production
export ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com

npm run start:prod
# CORS only allows specified origins
```
