# Chrome में Project Run करने के Steps

## Step 1: Backend Server Start करें

1. **Terminal खोलें** और root directory में जाएं:
   ```bash
   cd D:\apnizaroorat
   ```
npm install

2. **Server folder में जाएं**:
   ```bash
   cd server
   ```

3. **Server start करें**:
   ```bash
   npm run start:dev
   ```
   
   ✅ Server `http://localhost:3000/api` पर चल रहा होगा

---

## Step 2: Flutter App Chrome में Run करें

**नया Terminal खोलें** (पहला terminal server के लिए चलने दें):

1. **Bankers folder में जाएं**:
   ```bash
   cd D:\apnizaroorat\bankers
   ```

2. **Dependencies install करें** (अगर पहले नहीं किया):
   ```bash
   flutter pub get
   ```

3. **Chrome में run करें**:
   ```bash
   flutter run -d chrome
   ```
   
   **अगर white screen आए या font load error** (Roboto failed to fetch), ये try करें:
   ```bash
   flutter run -d chrome --web-renderer html
   ```
   
   या specific Chrome profile के साथ:
   ```bash
   flutter run -d chrome --web-browser-flag="--disable-web-security"
   ```

---

## Quick Commands (एक साथ)

**Terminal 1** (Backend):
```bash
cd D:\apnizaroorat\server
npm run start:dev
```

**Terminal 2** (Flutter):
```bash
cd D:\apnizaroorat\bankers
flutter run -d chrome
```

---

## Troubleshooting

### अगर Chrome में API call नहीं हो रही:
- Check करें कि backend server चल रहा है (`http://localhost:3000/api`)
- Browser console में errors check करें (F12 दबाएं)

### अगर CORS error आ रहा है:
- Server में CORS already enabled है, लेकिन अगर फिर भी problem है तो:
  ```bash
  flutter run -d chrome --web-browser-flag="--disable-web-security"
  ```

### Port already in use error:
- अगर port 3000 use में है, तो server के `.env` file में `PORT=3001` set करें

---

## Notes

- ✅ API config already `http://localhost:3000/api` पर set है (Chrome के लिए)
- ✅ Backend server पहले start होना चाहिए
- ✅ दो terminals चाहिए: एक server के लिए, एक Flutter के लिए
