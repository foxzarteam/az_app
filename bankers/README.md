# Apni Zaroorat (Bankers)

Flutter app + **NestJS API** backend. The app uses **REST APIs only** (no direct Supabase in Flutter). Supabase is connected from the **server** (at root level `/server`).

## Structure

```
apnizaroorat/
├── bankers/          # Flutter app
│   └── lib/          # Flutter code. All backend calls go through ApiService → HTTP to NestJS
└── server/           # NestJS API. Connects to Supabase, exposes /api/users/* and /api/otp/*
```

## Quick start

1. **Backend**
   ```bash
   # From root directory (apnizaroorat/)
   cd server
   npm install
   cp env.example .env   # set SUPABASE_URL, SUPABASE_SERVICE_KEY
   npm run start:dev
   ```
   API: `http://localhost:3000/api`

2. **Flutter**
   - Set `lib/config/api_config.dart` `baseUrl` if needed (e.g. `http://10.0.2.2:3000/api` for Android emulator).
   ```bash
   flutter pub get && flutter run
   ```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
