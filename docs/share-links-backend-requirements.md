# Share Links & Deep Linking — Backend Requirements

This document describes what the **backend / DevOps** team must provide so the Kingo User app can:

1. Generate shareable links from the app
2. Open the app when a user taps a shared link
3. Navigate to the correct screen inside the app

---

## 1. Share link APIs (already started)

Base API URL used by the app:

```
https://kango.laravelteam.site/api/v1/
```

### 1.1 Create share link

**Endpoint**

```
POST /api/v1/share-links
```

**Content-Type**

```
multipart/form-data
```

**Request body**

| Field | Type   | Required | Allowed values |
|-------|--------|----------|----------------|
| `type` | string | Yes | `product`, `offer`, `vendor`, `service_provider`, `service_type`, `provider_service` |
| `id`   | number/string | Yes | Entity ID |

**Example request**

```
type = product
id   = 6
```

**Expected response** `201 Created`

```json
{
  "success": true,
  "message": "Shared link generated.",
  "data": {
    "reference": "aKQ9NBN7mzs6KqTumKyAC0Q1ORgTyQ2d",
    "url": "https://kango.laravelteam.site/s/aKQ9NBN7mzs6KqTumKyAC0Q1ORgTyQ2d",
    "type": "product"
  }
}
```

**Important**

- `data.url` must be a **public HTTPS URL** in this format:

  ```
  https://kango.laravelteam.site/s/{reference}
  ```

- `reference` must be unique and stable.
- The app shares `data.url` with other apps (WhatsApp, etc.).

---

### 1.2 Resolve share link

**Endpoint**

```
GET /api/v1/share-links/{reference}/resolve
```

**Example**

```
GET /api/v1/share-links/aKQ9NBN7mzs6KqTumKyAC0Q1ORgTyQ2d/resolve
```

**Expected response** `200 OK`

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "type": "product",
    "id": 6,
    "screen": "product_details"
  }
}
```

**Fields**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Same values as create API (`product`, `offer`, `vendor`, `service_provider`, `service_type`, `provider_service`) |
| `id` | number | Yes | Target entity ID |
| `screen` | string | Yes | App screen key used for navigation (see section 2) |

**Error cases**

Return a normal API error response when:

- `reference` does not exist
- Link is expired / disabled
- Target entity was deleted

The app will ignore the deep link and continue normal splash navigation.

---

## 2. `screen` values expected by the mobile app

The app uses `data.screen` as the main routing key.

| `screen` value | Opens in app |
|----------------|--------------|
| `product_details` | Product details screen |
| `vendor_details` or `store_details` | Store / vendor details screen |
| `service_provider_details` | Service provider details screen |
| `provider_service_details` | Services store screen |
| `service_type_details` | Store screen filtered by service type |
| `offer_details` or `offers` | Offers list screen |

If `screen` is missing or unknown, the app falls back to `type`.

| `type` value | Fallback screen |
|--------------|-----------------|
| `product` | Product details |
| `vendor` | Store / vendor details |
| `service_provider` | Service provider details |
| `provider_service` | Services store screen |
| `service_type` | Store screen filtered by type |
| `offer` | Offers list |

**Recommendation for backend**

Always return a correct `screen` value. Example mapping:

| Share `type` | Recommended `screen` |
|--------------|----------------------|
| `product` | `product_details` |
| `vendor` | `vendor_details` |
| `offer` | `offer_details` |
| `service_provider` | `service_provider_details` |
| `service_type` | `service_type_details` |
| `provider_service` | `provider_service_details` |

---

## 3. Public web URL for shared links

Every shared link must open this path on the website domain:

```
https://kango.laravelteam.site/s/{reference}
```

### Required behavior

1. This URL must be publicly accessible.
2. If the mobile app is installed, the OS should open the app via deep linking (sections 4 and 5).
3. If the app is **not** installed, backend can optionally show a web fallback page (product preview, store page, or “Open in app / Download app”).

The mobile app extracts the reference from:

```
/s/{reference}
```

Examples:

- `https://kango.laravelteam.site/s/abc123`
- `https://kango.laravelteam.site/s/abc123/`

---

## 4. Android App Links (required for auto-open on Android)

Host this file on the domain:

```
https://kango.laravelteam.site/.well-known/assetlinks.json
```

**Requirements**

- Must be served over **HTTPS**
- `Content-Type: application/json`
- No redirect before serving the file

**Ready-to-use `assetlinks.json`**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.qeema.kingo.user",
      "sha256_cert_fingerprints": [
        "B3:6D:D9:DF:73:5F:C1:40:F2:C2:8A:47:C7:97:B7:19:1F:10:B0:B5:88:2B:AA:F3:59:B9:5A:1E:E5:39:8F:54",
        "81:ED:3B:16:5A:A5:6D:65:66:AD:0D:3E:C2:A5:E5:31:5F:95:3D:20:DB:6B:27:9D:11:BA:9E:7D:76:84:38:BB"
      ]
    }
  }
]
```

### Android SHA-256 fingerprints (Kingo User app)

| Build | Keystore | Alias | SHA-256 |
|-------|----------|-------|---------|
| **Debug** | `%USERPROFILE%\.android\debug.keystore` | `androiddebugkey` | `B3:6D:D9:DF:73:5F:C1:40:F2:C2:8A:47:C7:97:B7:19:1F:10:B0:B5:88:2B:AA:F3:59:B9:5A:1E:E5:39:8F:54` |
| **Release (upload key)** | `android/app/release.keystore` | `upload` | `81:ED:3B:16:5A:A5:6D:65:66:AD:0D:3E:C2:A5:E5:31:5F:95:3D:20:DB:6B:27:9D:11:BA:9E:7D:76:84:38:BB` |

**Important for production**

- The **release** fingerprint above is from the local **upload keystore**.
- If the app uses **Google Play App Signing**, also add the **App signing key certificate** SHA-256 from:
  - Google Play Console → **App integrity** → **App signing key certificate**
- Play Store installs are signed with Google's app signing key, not always the upload key.

### What backend needs from mobile team

- Android package name: `com.qeema.kingo.user`
- SHA-256 fingerprints: see table above (debug + release upload key)
- If published on Play Store: also add Play **App signing key** SHA-256 when available

Get fingerprint manually:

```bash
keytool -list -v -keystore your-release-key.jks -alias your-alias
```

Or from Google Play Console → App integrity → App signing key certificate.

### Android path covered by the app

```
https://kango.laravelteam.site/s/*
```

---

## 5. iOS Universal Links (required for auto-open on iOS)

Host this file on the domain:

```
https://kango.laravelteam.site/.well-known/apple-app-site-association
```

**Requirements**

- Must be served over **HTTPS**
- `Content-Type: application/json` (or `application/pkcs7-mime`)
- No `.json` extension in the URL
- No redirect before serving the file

**Template**

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "W5L74R7K79.com.qeema.kingo.user",
        "paths": ["/s/*"]
      }
    ]
  }
}
```

### iOS values

| Item | Value |
|------|-------|
| Apple Team ID | `W5L74R7K79` |
| Bundle ID | `com.qeema.kingo.user` |
| App ID | `W5L74R7K79.com.qeema.kingo.user` |
| Supported paths | `/s/*` |

---

## 6. End-to-end flow

```text
User taps Share in app
        ↓
App calls POST /api/v1/share-links
        ↓
Backend returns url: https://kango.laravelteam.site/s/{reference}
        ↓
User sends link to another user
        ↓
Recipient taps link
        ↓
OS opens Kingo app (if App Links / Universal Links are configured)
        ↓
App shows splash / GIF splash
        ↓
App calls GET /api/v1/share-links/{reference}/resolve
        ↓
Backend returns { type, id, screen }
        ↓
App navigates to the matching screen
```

---

## 7. Backend checklist

- [ ] `POST /api/v1/share-links` accepts `type` + `id` as form-data
- [ ] Create API returns `reference`, `url`, `type`
- [ ] Shared URL format is `https://kango.laravelteam.site/s/{reference}`
- [ ] `GET /api/v1/share-links/{reference}/resolve` returns `type`, `id`, `screen`
- [ ] `screen` values follow section 2
- [ ] Public route `/s/{reference}` exists on the website
- [ ] `/.well-known/assetlinks.json` is published (Android) with fingerprints from section 4
- [ ] `/.well-known/apple-app-site-association` is published (iOS)

---

## 8. Quick test commands

### Test resolve API

```bash
curl "https://kango.laravelteam.site/api/v1/share-links/aKQ9NBN7mzs6KqTumKyAC0Q1ORgTyQ2d/resolve"
```

### Test Android App Links file

```bash
curl "https://kango.laravelteam.site/.well-known/assetlinks.json"
```

### Test iOS association file

```bash
curl "https://kango.laravelteam.site/.well-known/apple-app-site-association"
```

### Test opening the app on Android (from mobile team)

```bash
adb shell am start -a android.intent.action.VIEW -d "https://kango.laravelteam.site/s/aKQ9NBN7mzs6KqTumKyAC0Q1ORgTyQ2d" com.qeema.kingo.user
```

---

## 9. Notes for backend

1. **Auth**: The mobile app currently calls create/resolve through the normal API client. Confirm whether these endpoints require authentication or should work for guests.
2. **Link lifetime**: If links expire, return a clear error on resolve so the app can skip navigation.
3. **Consistency**: `type`, `id`, and `screen` must always point to the same entity.
4. **Production domain**: If the production domain changes from `kango.laravelteam.site`, mobile app config and both well-known files must be updated together.
