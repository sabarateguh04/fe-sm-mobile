# SM-Mobile — Panduan Build APK & IPA

## Persiapan awal (sekali saja)

### 1. Dapatkan Google Maps API Key
1. Buka https://console.cloud.google.com
2. Buat project baru atau pilih yang sudah ada
3. Enable API:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Credentials → Create API Key → copy key-nya
5. Ganti `YOUR_GOOGLE_MAPS_API_KEY` di 3 tempat:
   - `android/app/src/main/AndroidManifest.xml`
   - `ios/Runner/Info.plist`
   - `ios/Runner/AppDelegate.swift`

### 2. Install dependencies
```bash
flutter pub get
```

---

## Build Android APK

### Debug APK (untuk testing, langsung install)
```bash
flutter build apk --debug
```
File: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (untuk distribusi)

**Step 1 — Buat keystore (sekali saja):**
```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```
Isi semua pertanyaan, catat password-nya.

**Step 2 — Isi `android/key.properties`:**
```
storePassword=password_keystore_kamu
keyPassword=password_key_kamu
keyAlias=upload
storeFile=upload-keystore.jks
```

**Step 3 — Build:**
```bash
# Satu APK universal
flutter build apk --release

# Split per arsitektur (lebih kecil, recommended)
flutter build apk --split-per-abi --release
```

File ada di `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-release.apk`   → HP modern (64-bit)
- `app-armeabi-v7a-release.apk` → HP lama (32-bit)
- `app-x86_64-release.apk`      → Emulator

**Install langsung ke HP via USB:**
```bash
flutter install
# atau
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## Build iOS IPA (butuh Mac + Xcode)

### Persiapan
```bash
cd ios
pod install
cd ..
```

### Debug (jalankan di simulator/device)
```bash
flutter run --release
```

### Release IPA

**Via command line:**
```bash
flutter build ios --release
# Lalu buka Xcode:
open ios/Runner.xcworkspace
# Product → Archive → Distribute App → Ad Hoc / Enterprise
```

**Via Xcode:**
1. Buka `ios/Runner.xcworkspace`
2. Pilih target device: "Any iOS Device (arm64)"
3. Product → Archive
4. Distribute App → pilih metode distribusi:
   - **Ad Hoc** → distribusi ke device terdaftar
   - **Enterprise** → distribusi internal tanpa App Store (butuh Apple Developer Enterprise Program)
   - **App Store** → upload ke App Store / TestFlight

---

## Distribusi APK Internal (tanpa Google Play)

Cara paling mudah untuk distribusi internal:

### Option A — Share langsung via link
Upload APK ke Google Drive / server, share link ke petugas.
Petugas: Settings → Install unknown apps → Allow.

### Option B — Portal download (web)
Hosting HTML sederhana dengan link download APK.
Bisa dihosting di server yang sama dengan backend API.

### Option C — Google Play Internal Testing
1. Buka https://play.google.com/console
2. Buat app baru → Internal Testing → Upload APK/AAB
3. Tambah email tester → mereka dapat link install

**AAB (Android App Bundle) untuk Play Store:**
```bash
flutter build appbundle --release
```
File: `build/app/outputs/bundle/release/app-release.aab`

---

## Checklist sebelum build release

- [ ] Ganti `YOUR_GOOGLE_MAPS_API_KEY` di semua file
- [ ] Ganti `baseUrl` di `ApiConfig` ke URL server production
- [ ] Ganti `applicationId` di `build.gradle` dari `com.example.sm_mobile`
      ke nama package resmi, misal: `com.polri.smmobile`
- [ ] Ganti `namespace` di `build.gradle` sama dengan `applicationId`
- [ ] Update `version` di `pubspec.yaml` (misal `1.0.0+1`)
- [ ] Test di device fisik sebelum distribusi
- [ ] Pastikan `android/key.properties` dan `.jks` tidak ter-commit ke git

---

## Troubleshooting umum

| Error | Solusi |
|-------|--------|
| `minSdkVersion` error | Pastikan `minSdkVersion 21` di `build.gradle` |
| Maps tidak muncul | Cek API Key, pastikan Maps SDK for Android sudah di-enable |
| HTTP gagal di release | Pastikan `android:usesCleartextTraffic="true"` di `AndroidManifest.xml` |
| `DexArchiveMergerException` | Tambah `multiDexEnabled true` di `defaultConfig` |
| iOS pod install gagal | Jalankan `pod repo update` lalu `pod install` ulang |
