# नए System में Project Setup करने के Steps

## Step 1: Git Pull करें

```bash
# Project folder में जाएं
cd D:\apnizaroorat

# Git pull करें
git pull origin main
```

---

## Step 2: Backend Server Setup

```bash
# Server folder में जाएं
cd server

# Dependencies install करें
npm install

# .env file बनाएं (env.example से copy करें)
copy env.example .env

# .env file में Supabase credentials set करें
# SUPABASE_URL और SUPABASE_SERVICE_KEY add करें
```

**`.env` file में ये values set करें:**
```
SUPABASE_URL=https://udimpjtffznuuebwiozv.supabase.co
SUPABASE_SERVICE_KEY=your-service-key-here
PORT=3000
API_PREFIX=api
```

**Server start करें:**
```bash
npm run start:dev
```

✅ Server `http://localhost:3000/api` पर चलेगा

---

## Step 3: Flutter App Setup

**नया Terminal खोलें** (पहला terminal server के लिए चलने दें):

```bash
# Bankers folder में जाएं
cd D:\apnizaroorat\bankers

# Flutter dependencies install करें
flutter pub get

# Flutter doctor check करें (optional)
flutter doctor
```

---

## Step 4: App Run करें

### Chrome में Run करने के लिए:
```bash
cd D:\apnizaroorat\bankers
flutter run -d chrome
```

### Android Device/Emulator में Run करने के लिए:
```bash
cd D:\apnizaroorat\bankers
flutter run
```

### Specific Device चुनने के लिए:
```bash
# Available devices देखें
flutter devices

# Specific device पर run करें
flutter run -d <device-id>
```

---

## Quick Commands Summary

### Terminal 1 (Backend):
```bash
cd D:\apnizaroorat\server
npm install
copy env.example .env
# .env file edit करें
npm run start:dev
```

### Terminal 2 (Flutter):
```bash
cd D:\apnizaroorat\bankers
flutter pub get
flutter run -d chrome
```

---

## Important Notes

1. **पहले Backend Server start करें**, फिर Flutter app
2. **`.env` file** में Supabase credentials जरूरी हैं
3. **Chrome** के लिए API config: `http://localhost:3000/api`
4. **Real Device** के लिए API config में computer का IP address use करें

---

## Troubleshooting

### अगर npm install में error आए:
```bash
cd server
npm cache clean --force
npm install
```

### अगर flutter pub get में error आए:
```bash
cd bankers
flutter clean
flutter pub get
```

### अगर server start नहीं हो रहा:
- Check करें `.env` file में credentials सही हैं
- Port 3000 available है या नहीं

### अगर Flutter app API connect नहीं कर रहा:
- Check करें backend server चल रहा है
- API config में correct URL है

---

## Project Structure

```
apnizaroorat/
├── bankers/          # Flutter app
│   └── lib/          # Flutter code
└── server/           # NestJS backend
    └── src/          # Server code
```

---

## Environment Requirements

- **Node.js** (v16+ recommended)
- **Flutter SDK** (latest stable)
- **Git**
- **Supabase Account** (for database)
