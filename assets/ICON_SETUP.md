# App Icon Setup Instructions

## To add your Apni Zaroorat app icon:

1. **Save your icon image** (the handshake with gold coin on red background) as `app_icon.png` in the `assets` folder
   - Recommended size: 1024x1024 pixels (square)
   - Format: PNG with transparent background (if needed)
   - The icon should show:
     - Red background
     - Handshake in the center (two hands with red sleeves)
     - Gold coin behind the handshake
     - "Apni Zaroorat" text below (optional, as Android will show the app name separately)

2. **Generate the launcher icons** by running:
   ```
   flutter pub run flutter_launcher_icons
   ```

3. **Rebuild the APK** with the new icon:
   ```
   flutter build apk --release
   ```

The new APK will be located at: `build\app\outputs\flutter-apk\app-release.apk`

## Current Status:
✅ APK built successfully at: `build\app\outputs\flutter-apk\app-release.apk`
✅ App name set to "Apni Zaroorat" in AndroidManifest.xml
⏳ Waiting for icon image to be added
