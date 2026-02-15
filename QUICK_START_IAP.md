# Quick Setup - In-App Purchases

## ✅ Immediate Actions Needed

### 1. Update Product ID (Required)
**File**: `SubscriptionManager.swift`, line 12

Change this:
```swift
private let productID = "com.yourcompany.leadershipnotes.monthly"
```

To your actual product ID. It should match your bundle identifier format:
```swift
private let productID = "com.YOURBUNDLEID.leadershipnotes.monthly"
```

### 2. Update Privacy/Terms URLs (Required)
**File**: `PaywallView.swift`, around line 185

Change these URLs to your actual website:
```swift
Link("Privacy Policy", destination: URL(string: "https://YOURWEBSITE.com/privacy-policy.html")!)
Link("Terms of Service", destination: URL(string: "https://YOURWEBSITE.com/terms-of-service.html")!)
```

### 3. Configure StoreKit File (For Testing)
**File**: `LeadershipNotes.storekit`

1. Open in Xcode
2. Click on the subscription product
3. Update Product ID to match step 1
4. Verify price shows $0.99
5. Verify intro offer shows 7 days free

### 4. Enable StoreKit in Scheme (For Testing)
1. Xcode → Product → Scheme → Edit Scheme
2. Select "Run" → "Options" tab
3. StoreKit Configuration → Select `LeadershipNotes.storekit`
4. Run the app!

---

## 🚀 App Store Connect Setup (For Production)

### When Ready to Submit:

1. **Create Subscription in App Store Connect**
   - Product ID: Same as in code
   - Price: $0.99/month
   - Free Trial: 7 days, 1 period

2. **Add Metadata**
   - Display Name: "Monthly Subscription"
   - Description: Your subscription description

3. **Submit for Review**
   - Include valid Privacy Policy URL
   - Include valid Terms of Service URL

---

## 🧪 Testing

### Test Locally (No Account Needed)
Just run the app with StoreKit configuration enabled (step 4 above).

### Test on Device (Optional)
1. Create sandbox tester in App Store Connect
2. Sign out of Apple ID on test device
3. Run app and sign in with sandbox account

---

## 📱 What Users Will See

1. **First Launch**: Full-screen paywall
2. **After Free Trial Starts**: Paywall dismisses, app is usable
3. **In Settings**: Subscription status card showing:
   - ✅ Free Trial (during first 7 days)
   - ✅ Active (after trial, if not cancelled)
   - ❌ Not Subscribed (if they never subscribed)
   - ⚠️ Expired (if subscription lapsed)

---

## 💰 Pricing Structure

- **Free Trial**: 7 days (full access)
- **After Trial**: $0.99/month
- **Cancellation**: Anytime via iOS Settings
- **Your Revenue**: ~$0.70/month per user (year 1), ~$0.84/month (year 2+)

---

## ⚠️ Important Notes

- Product ID in code **must match** App Store Connect
- Privacy Policy and Terms URLs **must be valid** for App Review
- Users can restore purchases on new devices
- Subscription status persists across app launches
- All transactions are verified by Apple

---

## 📚 Full Documentation

See `IAP_SETUP_GUIDE.md` for complete details and troubleshooting.
