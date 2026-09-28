# iOS Build Setup Guide

This guide will help you configure iOS builds for CI/CD with Telegram notifications.

## Prerequisites

- Apple Developer Account
- Code Signing Certificate
- Provisioning Profile
- GitHub repository with Actions enabled

## Quick Setup

### 1. Configure ExportOptions.plist

Edit `ios/ExportOptions.plist` and update:

```xml
<key>teamID</key>
<string>YOUR_TEAM_ID</string>  <!-- Find in Apple Developer Portal -->

<key>provisioningProfiles</key>
<dict>
    <key>com.yourcompany.heraj</key>  <!-- Your Bundle ID -->
    <string>YOUR_PROVISIONING_PROFILE_NAME</string>  <!-- Profile name -->
</dict>
```

**Finding Your Team ID:**
1. Go to https://developer.apple.com/account
2. Click on "Membership"
3. Copy the Team ID

### 2. Export Code Signing Certificate

**On macOS:**

1. Open **Keychain Access**
2. Select **My Certificates** from the left sidebar
3. Find your **iPhone Distribution** certificate
4. Right-click → **Export**
5. Save as `.p12` file with a password
6. Convert to Base64:
   ```bash
   base64 -i YourCertificate.p12 | pbcopy
   ```

### 3. Export Provisioning Profile

**On macOS:**

1. Download your provisioning profile from Apple Developer Portal
2. Or find it in:
   ```bash
   ~/Library/MobileDevice/Provisioning\ Profiles/
   ```
3. Convert to Base64:
   ```bash
   base64 -i YourProfile.mobileprovision | pbcopy
   ```

### 4. Add GitHub Secrets

Go to your repository → Settings → Secrets and variables → Actions

Add the following secrets:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `TELEGRAM_BOT_TOKEN` | Bot token | From @BotFather (ask a maintainer) |
| `TELEGRAM_CHAT_ID` | Chat ID | Target group chat ID (ask a maintainer) |
| `IOS_CERTIFICATE_BASE64` | Base64 certificate | From step 2 |
| `IOS_CERTIFICATE_PASSWORD` | Certificate password | Password you set in step 2 |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64 profile | From step 3 |

### 5. Update Bundle ID (if needed)

Check `ios/Runner.xcodeproj/project.pbxproj` and `ios/Runner/Info.plist` to ensure your Bundle ID matches the provisioning profile.

## Build Types

### Development Build (Unsigned)

**Workflow:** `send_telegram_ipa.yml`

**Trigger:** Push to `main` branch

**Use Case:** Quick testing, no code signing required

```bash
# Automatically triggered on push to main
git push origin main
```

### Production Build (Signed)

**Workflow:** `send_telegram_ipa_signed.yml`

**Trigger:** Version tags

**Use Case:** Distribution, App Store, TestFlight

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

## Testing the Workflow

### Manual Trigger

1. Go to GitHub → Actions
2. Select workflow (e.g., "Build and Send Telegram IPA")
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow" button

### Expected Output

When successful, you'll receive a Telegram message with:

- 🍎 IPA file attachment
- 📦 Version number
- 🔨 Build number
- 👤 Commit author
- 📝 Commit message
- 📅 Build date

## Troubleshooting

### Common Issues

#### 1. "No valid code signing identity found"

**Solution:** Ensure `IOS_CERTIFICATE_BASE64` and `IOS_CERTIFICATE_PASSWORD` are correctly set in GitHub Secrets.

#### 2. "Provisioning profile doesn't match"

**Solution:** 
- Check Bundle ID matches in `ExportOptions.plist`
- Verify provisioning profile is for the correct Bundle ID
- Ensure provisioning profile includes your certificate

#### 3. "Build failed: Could not find module"

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### 4. "Telegram message not sent"

**Solution:**
- Verify `TELEGRAM_BOT_TOKEN` is correct
- Verify `TELEGRAM_CHAT_ID` is correct
- Check bot has permission to send messages to the group

### Getting More Info

Enable debug logging in the workflow:

```yaml
- name: Build iOS IPA
  run: |
    flutter build ipa --release --verbose
```

## Distribution Methods

### Ad-Hoc Distribution (Current)

Suitable for testing on registered devices.

```xml
<key>method</key>
<string>ad-hoc</string>
```

### App Store Distribution

For TestFlight and App Store:

```xml
<key>method</key>
<string>app-store</string>
```

### Enterprise Distribution

For internal enterprise distribution:

```xml
<key>method</key>
<string>enterprise</string>
```

## Important Notes

⚠️ **Security:**
- Never commit certificates or provisioning profiles to the repository
- Use GitHub Secrets for all sensitive data
- Rotate certificates periodically

⚠️ **Limits:**
- macOS runners are billed at 10x the rate of Linux runners
- Consider triggering builds only on tags for production

⚠️ **File Size:**
- Telegram has a 50MB file size limit for bots
- If IPA exceeds this, consider uploading to a file host and sending the link

## Need Help?

Check the CI-CD.md file for additional configuration options and troubleshooting steps.

---

**Last Updated:** January 2026

