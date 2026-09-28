# How to Get Android SHA-1 Fingerprint

This guide shows you how to get the SHA-1 fingerprint for your Android app. You'll need this for Firebase, Google Sign-In, and other services.

## Method 1: Using Gradle (Easiest - Recommended)

### For Debug Build:
```bash
cd android
./gradlew signingReport
```

**Windows:**
```bash
cd android
gradlew signingReport
```

This will show SHA-1 and SHA-256 for both debug and release keystores.

---

## Method 2: Using Keytool Command

### For Debug Keystore (Development):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Windows:**
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Output:** Look for `SHA1:` in the output.

---

### For Release Keystore (Production):

If you have a release keystore, use:

```bash
keytool -list -v -keystore <path-to-your-keystore> -alias <your-key-alias>
```

**Example:**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias <your-alias>
```

You'll be prompted for the keystore password and key password.

---

## Method 3: Using Android Studio

1. Open Android Studio
2. Open your project
3. Click on **Gradle** tab (right side)
4. Navigate to: `android` → `Tasks` → `android` → `signingReport`
5. Double-click `signingReport`
6. Check the **Run** tab at the bottom for SHA-1 and SHA-256

---

## Quick Commands for Your Project

Based on your project structure, here are the exact commands:

### Debug SHA-1:
**Windows PowerShell:**
```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Windows CMD:**
```cmd
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Linux/Mac:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Release SHA-1 (Your Production Keystore):
**Windows PowerShell:**
```powershell
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload -storepass 12345678 -keypass 12345678
```

**Windows CMD:**
```cmd
keytool -list -v -keystore android\app\upload-keystore.jks -alias upload -storepass 12345678 -keypass 12345678
```

**Linux/Mac:**
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload -storepass 12345678 -keypass 12345678
```

---

## ✅ Your Current SHA-1 Fingerprints

### Debug Keystore SHA-1 (Development):
```
22:AD:38:8C:94:09:46:60:BC:15:D9:5F:72:69:E4:D0:07:FE:96:95
```

### Debug Keystore SHA-256:
```
4B:7C:40:26:72:EF:AA:D3:DB:11:80:A2:B2:DC:9C:21:88:C3:0E:46:39:95:3F:21:6F:85:C3:6A:F6:31:1B:FF
```

---

### Release Keystore SHA-1 (Production):
```
40:3C:5B:49:CE:BC:42:32:C3:36:F4:19:16:E6:E3:79:77:3C:FA:21
```

### Release Keystore SHA-256:
```
2F:D7:00:9E:C8:3B:13:BF:62:DD:34:98:6F:13:86:CD:65:84:3E:22:16:80:81:4E:3A:9D:CF:30:45:98:17:EF
```

---

## 📝 Important Notes

1. **For Firebase/Google Sign-In:** Add BOTH Debug and Release SHA-1 fingerprints
2. **Debug SHA-1:** Use for development and testing
3. **Release SHA-1:** Use for production builds and Play Store
4. **Format:** You can use with or without colons (both work):
   - With colons: `40:3C:5B:49:CE:BC:42:32:C3:36:F4:19:16:E6:E3:79:77:3C:FA:21`
   - Without colons: `403C5B49CEBC4232C336F41916E6E379773CFA21`

---

## What to Look For

After running the command, you'll see output like:

```
Certificate fingerprints:
     SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
     SHA256: 11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11
```

Copy the **SHA1** value (without spaces or colons, or with colons depending on what the service requires).

---

## For Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** → **Your apps** → **Android app**
4. Click **Add fingerprint**
5. Paste your SHA-1 fingerprint

---

## Troubleshooting

### If keytool is not found:
- Make sure Java JDK is installed
- Add Java bin directory to your PATH
- Or use full path: `"C:\Program Files\Java\jdk-XX\bin\keytool.exe"`

### If keystore file not found:
- Debug keystore is usually at: `~/.android/debug.keystore` (Linux/Mac) or `%USERPROFILE%\.android\debug.keystore` (Windows)
- For release, check your `key.properties` file for the keystore path

---

**Last Updated:** February 18, 2026

