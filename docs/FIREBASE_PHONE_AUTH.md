# Firebase Phone OTP — fix "missing initial state"

That browser error means Firebase opened **web reCAPTCHA** because **Android SHA keys are not registered** in Firebase Console.

## Fix (production — real SMS on phone)

1. Open [Firebase Console](https://console.firebase.google.com/) → project **azapp-77130** → ⚙️ Project settings → Your apps → Android `com.example.mobile`.
2. Add **SHA-1** and **SHA-256** (debug build):

   ```
   SHA-1:   30:0E:C0:D6:91:18:ED:44:7C:B5:3D:B8:FB:37:1B:5A:F2:C7:D9:28
   SHA-256: 7A:54:DB:6F:87:1D:80:8A:F4:79:11:99:22:EA:C8:E3:87:B3:C3:11:61:9A:0B:0C:CA:F6:3A:29:5A:D4:46:32
   ```

   Release build: run the same `keytool` on your **release keystore** and add those fingerprints too.

3. Download new **google-services.json** → replace `android/app/google-services.json`.
4. Rebuild: `flutter clean && flutter run`.
5. Enable **Phone** sign-in: Authentication → Sign-in method → Phone.

After SHA is added, OTP uses **native verification** (no browser, no sessionStorage error).

## Dev / until SHA is added

- App **auto-falls back** to server OTP if Firebase browser fails.
- Or set in `lib/config/app_config.dart`: `forceBackendOtp = true`
- Or set `LIVE=false` in `server/.env` — OTP on `https://…/api/otp/dev`

Regenerate debug SHA:

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```
