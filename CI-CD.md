# CI/CD Configuration

This document describes the CI/CD configuration for the project. Credentials are never stored in the repository; they live in GitHub Actions secrets.

## Telegram Bot Integration

Telegram notifications in the CI/CD pipeline read these values from secrets:

### Environment Variables

```bash
TELEGRAM_CHAT_ID=<chat id of the target group>
TELEGRAM_BOT_TOKEN=<token from @BotFather>
```

### Usage

These credentials are used to send build notifications, deployment status updates, and alerts to the configured Telegram chat.

#### Setting up in GitHub Actions

Add these as repository secrets:

1. Go to your GitHub repository
2. Navigate to `Settings` > `Secrets and variables` > `Actions`
3. Add the following secrets:
   - `TELEGRAM_CHAT_ID`: chat ID of the target group (ask a maintainer)
   - `TELEGRAM_BOT_TOKEN`: bot token from @BotFather (ask a maintainer)

#### Setting up in GitLab CI

Add these as CI/CD variables:

1. Go to your GitLab project
2. Navigate to `Settings` > `CI/CD` > `Variables`
3. Add the following variables:
   - `TELEGRAM_CHAT_ID`: chat ID of the target group (ask a maintainer)
   - `TELEGRAM_BOT_TOKEN`: bot token from @BotFather (ask a maintainer)

## Security Notes

- ⚠️ Keep these credentials secure and never commit them directly to the repository
- ⚠️ Use environment variables or CI/CD secrets management
- ⚠️ Rotate tokens periodically for enhanced security
- ⚠️ Limit bot permissions to only what's necessary

## GitHub Actions Workflows

### Available Workflows

#### 1. `send_telegram_apk.yml`
Builds and sends Android APK to Telegram on every push to `main` branch.

**Trigger:** Push to `main`

**Output:** `app-release.apk`

#### 2. `send_telegram_ipa.yml`
Builds unsigned iOS IPA (for testing) and sends to Telegram.

**Trigger:** 
- Push to `main`
- Manual workflow dispatch

**Output:** `app-release.ipa` (unsigned)

**Note:** This creates an unsigned IPA suitable for testing. Not for App Store distribution.

#### 3. `send_telegram_ipa_signed.yml`
Builds signed iOS IPA (production-ready) and sends to Telegram.

**Trigger:** 
- Push tags matching `v*` (e.g., v1.0.0)
- Manual workflow dispatch

**Output:** `heraj.ipa` (signed)

**Requirements:** Requires the following secrets to be set:
- `IOS_CERTIFICATE_BASE64` - Base64 encoded .p12 certificate
- `IOS_CERTIFICATE_PASSWORD` - Certificate password
- `IOS_PROVISIONING_PROFILE_BASE64` - Base64 encoded provisioning profile

### Setting Up iOS Code Signing

To enable signed iOS builds, you need to add the following secrets:

1. **Export your certificate as .p12:**
   ```bash
   # From Keychain Access, export as .p12 file
   # Then convert to base64
   base64 -i YourCertificate.p12 | pbcopy
   ```

2. **Export provisioning profile:**
   ```bash
   # Copy from ~/Library/MobileDevice/Provisioning Profiles/
   base64 -i YourProfile.mobileprovision | pbcopy
   ```

3. **Add to GitHub Secrets:**
   - `IOS_CERTIFICATE_BASE64`: Paste the certificate base64
   - `IOS_CERTIFICATE_PASSWORD`: Your certificate password
   - `IOS_PROVISIONING_PROFILE_BASE64`: Paste the profile base64

### Manual Workflow Trigger

To manually trigger any workflow:

1. Go to your GitHub repository
2. Click on `Actions` tab
3. Select the workflow you want to run
4. Click `Run workflow`
5. Select the branch and click `Run workflow`

## Fastlane

Fastlane is set up for both Android and iOS to standardize builds locally and in CI.

### Prerequisites (local)

You need **Ruby** and **Bundler**. If `bundle` is not found:

- **Windows:** Install [Ruby+Devkit](https://rubyinstaller.org/downloads/), then in a new terminal:
  ```bash
  gem install bundler
  ```
- **macOS:** Ruby is usually preinstalled; if needed: `gem install bundler` or `brew install ruby`.
- **Linux:** `sudo apt install ruby ruby-dev bundler` (or equivalent).

Then from the project root:

```bash
bundle install
```

### Android (Google Play updates only)

One lane: build AAB and upload to your existing app on Google Play.

Set your Play Console service account JSON path, then run:

```bash
export SUPPLY_JSON_KEY="/path/to/your-play-service-account.json"
bundle exec fastlane android update
```

From project root. Default track is **production**. For internal/beta: `bundle exec fastlane android update track:internal` (or `track:beta`).  
In CI, you can set `SUPPLY_JSON_KEY_DATA` to the JSON string instead of a file path.

### iOS (App Store updates only)

One lane: build signed IPA and upload to your existing app on App Store Connect.

You need: **ExportOptions.plist**, code signing (certificate + provisioning profile), and Apple credentials (Apple ID + app-specific password, or App Store Connect API key). Then run:

```bash
bundle exec fastlane ios update
```

From project root. The build is uploaded to TestFlight; release to App Store from App Store Connect when ready.

---

## Additional Configuration

### Notification Types

The Telegram bot sends notifications for:

- ✅ Build succeeded (with download link)
- ❌ Build failed (with error details)
- 🍎 iOS IPA ready (unsigned/signed)
- 🤖 Android APK ready
- 📦 Version information
- 👤 Commit author
- 📝 Commit message
- 🔨 Build number

### Customizing Notifications

You can customize the notification message by editing the `CAPTION` variable in the workflow files.

---

**Last Updated:** January 2026

