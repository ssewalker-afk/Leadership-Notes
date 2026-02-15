# In-App Purchase Setup Guide

## Overview
Leadership Notes uses StoreKit 2 with a subscription model:
- **7-day free trial**
- **$0.99/month** after trial
- Auto-renewable subscription

## Files Added
1. `SubscriptionManager.swift` - Handles all StoreKit logic
2. `PaywallView.swift` - Beautiful paywall UI
3. `LeadershipNotes.storekit` - StoreKit configuration for testing
4. Updated `ContentView.swift` - Integrates paywall
5. Updated `SettingsView.swift` - Shows subscription status

## Setup Steps

### 1. Update Product ID
In `SubscriptionManager.swift`, line 12, update the product ID:
```swift
private let productID = "com.yourcompany.leadershipnotes.monthly"
```

Replace `yourcompany` with your actual bundle identifier prefix.

### 2. Configure StoreKit Configuration File
1. Open `LeadershipNotes.storekit` in Xcode
2. Update the product ID to match your bundle identifier
3. Verify the price is $0.99
4. Confirm the intro offer is set to 7 days free trial

### 3. Set Up in App Store Connect

#### Create the Subscription
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **In-App Purchases** → **Subscriptions**
4. Click **+** to create a new subscription group
5. Name it "Premium" or similar
6. Create a new subscription with:
   - **Product ID**: `com.yourcompany.leadershipnotes.monthly` (must match code)
   - **Reference Name**: "Monthly Subscription"
   - **Subscription Duration**: 1 month
   - **Price**: $0.99

#### Configure Free Trial
1. In the subscription details, go to **Subscription Prices**
2. Click **Add Introductory Offer**
3. Select:
   - **Type**: Free
   - **Duration**: 7 days
   - **Number of periods**: 1
4. Click **Save**

#### Add Localization
1. Add at least one localization (English recommended)
2. Fill in:
   - **Subscription Display Name**: "Monthly Subscription"
   - **Description**: "Professional coaching documentation with unlimited entries, reports, and backups"

### 4. Test in Xcode

#### Using StoreKit Configuration (Local Testing)
1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** in the left sidebar
3. Go to **Options** tab
4. Under **StoreKit Configuration**, select `LeadershipNotes.storekit`
5. Run the app - no sandbox account needed!

#### Test Scenarios
- ✅ Launch app → See paywall
- ✅ Start free trial → Access app
- ✅ Restore purchases (should fail if no purchase)
- ✅ Close and reopen → Should remember subscription
- ✅ Check Settings → See subscription status

### 5. Test with Sandbox Account (Optional)

#### Create Sandbox Tester
1. Go to App Store Connect
2. **Users and Access** → **Sandbox** → **Testers**
3. Click **+** to add a new sandbox tester
4. Use a fake email (doesn't need to be real)
5. Choose a region (USA recommended)

#### Test on Device
1. Sign out of your Apple ID on the test device
2. Run the app from Xcode
3. When prompted to sign in, use sandbox account
4. Test the purchase flow
5. Verify subscription appears in Settings

### 6. Update URLs in PaywallView

In `PaywallView.swift`, update these URLs (around line 185):
```swift
Link("Privacy Policy", destination: URL(string: "https://yourwebsite.com/privacy-policy.html")!)
Link("Terms of Service", destination: URL(string: "https://yourwebsite.com/terms-of-service.html")!)
```

Replace with your actual privacy policy and terms URLs.

### 7. App Review Requirements

Before submitting to App Review, ensure:
- [ ] Privacy Policy URL is valid and accessible
- [ ] Terms of Service URL is valid and accessible  
- [ ] Subscription terms are clearly displayed
- [ ] Restore Purchases button works
- [ ] Price is displayed correctly ($0.99/month)
- [ ] Free trial terms are clear (7 days free)
- [ ] App has a way to use basic features without subscription (or justify paywall)

**Note**: Apple may reject if ALL features require subscription with no free tier. Consider offering a limited free version, or be prepared to justify the paywall in your review notes.

## Troubleshooting

### "Product not found" error
- Verify product ID matches in code and StoreKit config
- Make sure StoreKit configuration is selected in scheme
- Clean build folder (⌘⇧K) and rebuild

### Paywall doesn't dismiss after purchase
- Check `subscriptionManager.isSubscribed` is updating
- Verify transaction verification is working
- Check console for any StoreKit errors

### "Restore Purchases" finds nothing
- This is normal if you haven't made a purchase yet
- Try making a purchase first, then test restore
- In sandbox testing, purchases can be cleared in Settings → App Store → Sandbox Account

### Subscription status shows "unknown"
- Wait a few seconds - it needs to check with StoreKit
- Check console for any errors from `updateSubscriptionStatus()`
- Verify StoreKit configuration is properly loaded

## Testing Checklist

- [ ] Paywall appears on first launch
- [ ] "Start Free Trial" button works
- [ ] After purchase, paywall dismisses
- [ ] Subscription status shows correctly in Settings
- [ ] App reopens without showing paywall (if subscribed)
- [ ] Restore purchases works
- [ ] Links to Privacy Policy and Terms work
- [ ] Price displays correctly
- [ ] Free trial terms are clear

## Production Deployment

1. Complete App Store Connect setup (above)
2. Submit app for review
3. In review notes, explain:
   - Why app requires subscription
   - What users get with subscription
   - Free trial details
4. Wait for approval
5. Once approved, subscriptions will work automatically

## Support

If users have subscription issues:
1. Guide them to Settings → Subscription
2. Tap "Manage Subscription" (opens App Store)
3. Or contact Apple Support directly at reportaproblem.apple.com

## Revenue

- Apple takes 30% first year (you get 70%)
- Apple takes 15% after first year (you get 85%)
- At $0.99/month, you earn ~$0.70/month per user first year
- After year 1: ~$0.84/month per user

## Notes

- Free trial automatically converts to paid subscription
- Users can cancel anytime from iOS Settings
- Refunds are handled by Apple
- You can see revenue in App Store Connect
- Subscription auto-renews monthly unless cancelled
