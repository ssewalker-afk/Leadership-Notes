# Legal Documents - Leadership Notes

This directory contains the legal documents for the Leadership Notes app, published via GitHub Pages for App Store compliance.

## Published URLs

After enabling GitHub Pages, these documents will be available at:

- **Landing Page**: `https://YOUR-USERNAME.github.io/leadership-notes/`
- **Privacy Policy**: `https://YOUR-USERNAME.github.io/leadership-notes/privacy-policy.html`
- **Terms of Service**: `https://YOUR-USERNAME.github.io/leadership-notes/terms-of-service.html`

## Setup Instructions

### 1. Enable GitHub Pages

1. Go to your repository on GitHub.com
2. Click **Settings** → **Pages**
3. Under **Source**, select:
   - Branch: `main`
   - Folder: `/ (root)`
4. Click **Save**
5. Wait 2-3 minutes for deployment

### 2. Verify Deployment

Visit your URLs to confirm they're live and accessible.

### 3. Update App Store Connect

Add these URLs to your App Store Connect listing:

1. Log in to **App Store Connect**
2. Go to **My Apps** → Select your app
3. Navigate to **App Information**
4. Add URLs:
   - **Privacy Policy URL**: Your privacy-policy.html link
   - **Terms of Service URL**: Your terms-of-service.html link (if required)

### 4. Update URLs in Your App

**Important**: Replace `YOUR-USERNAME` in `SettingsView.swift` with your actual GitHub username:

```swift
// In SettingsView.swift, update these lines:
Link(destination: URL(string: "https://YOUR-USERNAME.github.io/leadership-notes/privacy-policy.html")!)
Link(destination: URL(string: "https://YOUR-USERNAME.github.io/leadership-notes/terms-of-service.html")!)
```

### 5. Update Contact Email

Replace `support@example.com` with your actual support email in:
- `privacy-policy.html`
- `terms-of-service.html`

## Files

- **index.html** - Landing page with links to legal documents
- **privacy-policy.html** - Privacy policy for the app
- **terms-of-service.html** - Terms of service and subscription information

## Maintenance

### Updating Legal Documents

1. Edit the HTML files as needed
2. Update the "Last updated" date
3. Commit and push changes to GitHub
4. Changes will be live within a few minutes

### Version Updates

When releasing new app versions, update the version number in:
- `SettingsView.swift` (Legal section)
- Consider updating legal docs if needed

## Apple App Store Requirements

Apple requires:

✅ **Privacy Policy** - Required for all apps
✅ **Terms of Service** - Recommended, especially for apps with subscriptions
✅ **Publicly accessible URLs** - Must be reachable without authentication
✅ **Contact information** - Must provide a way for users to contact you

## Compliance

These documents are designed to comply with:
- **Apple App Store Guidelines**
- **GDPR** (General Data Protection Regulation)
- **CCPA** (California Consumer Privacy Act)
- **Auto-renewable subscription requirements**

## Notes

- All data in Leadership Notes is stored locally on device
- No servers, no analytics, no tracking
- Subscriptions are handled entirely through Apple's App Store
- We never collect, access, or have any user data

---

**Need help?** Check the [Apple App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/) for the latest requirements.
