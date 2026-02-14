# Bankers API (NestJS)

Backend for **Apni Zaroorat** app. Uses Supabase as database. All app flows use REST APIs only.

## Setup

1. **Install**
   ```bash
   # From root directory (apnizaroorat/)
   cd server
   npm install
   ```

2. **Env**
   - Copy `env.example` to `.env`
   - Set `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` (Supabase Dashboard → Settings → API)
   - Optional: `FAST2SMS_API_KEY` for OTP SMS. If missing, OTP is logged to console.

3. **Run**
   ```bash
   npm run start:dev
   ```
   API: `http://localhost:3000/api`

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/users/mobile/:mobile` | Get user by mobile |
| POST | `/api/users` | Create user |
| PUT | `/api/users/upsert` | Upsert user (create or update) |
| PATCH | `/api/users/mobile/:mobile/mpin` | Update MPIN |
| PATCH | `/api/users/mobile/:mobile/login-status` | Update login status |
| PATCH | `/api/users/mobile/:mobile/profile` | Update profile |
| POST | `/api/otp/send` | Send OTP `{ "mobileNumber": "9876543210" }` |
| POST | `/api/otp/verify` | Verify OTP `{ "mobileNumber": "...", "otp": "1234" }` |

## Project layout

- `src/config/` – Supabase client
- `src/users/` – User CRUD + upsert, mpin, login-status, profile
- `src/otp/` – OTP send + verify (otp_sessions + optional Fast2SMS)
