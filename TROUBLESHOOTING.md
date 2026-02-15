# Troubleshooting Guide

## Common Issues and Solutions

### 🚫 Issue: "Product not found" error

**Symptoms:**
- Paywall shows but "Start Free Trial" button is disabled
- Console shows: "Failed to load products"
- `subscriptionManager.monthlyProduct` is nil

**Solutions:**

1. **Check Product ID matches everywhere**
   ```swift
   // In SubscriptionManager.swift
   private let productID = "com.yourcompany.leadershipnotes.monthly"
   
   // In LeadershipNotes.storekit
   "productID" : "com.yourcompany.leadershipnotes.monthly"
   ```
   These MUST be identical!

2. **Verify StoreKit configuration is selected**
   - Xcode → Product → Scheme → Edit Scheme
   - Run → Options tab
   - StoreKit Configuration should show "LeadershipNotes.storekit"
   - If not, select it from dropdown

3. **Clean and rebuild**
   ```
   ⌘⇧K (Clean Build Folder)
   ⌘B (Build)
   ```

4. **Check StoreKit file is in target**
   - Select `LeadershipNotes.storekit` in project navigator
   - Check File Inspector (right sidebar)
   - Verify your target is checked under "Target Membership"

---

### 🚫 Issue: Paywall doesn't dismiss after purchase

**Symptoms:**
- "Start Free Trial" works
- Purchase completes
- But paywall stays on screen

**Solutions:**

1. **Check subscription status is updating**
   - Add breakpoint in `SubscriptionManager.updateSubscriptionStatus()`
   - Should be called after purchase
   - Should change `subscriptionStatus` to `.inFreeTrial` or `.subscribed`

2. **Verify onChange is working**
   ```swift
   // In ContentView.swift - make sure this exists
   .onChange(of: subscriptionManager.subscriptionStatus) { oldValue, newValue in
       if subscriptionManager.isSubscribed {
           showPaywall = false  // This should dismiss
       }
   }
   ```

3. **Check for SwiftUI state issues**
   - Make sure `subscriptionManager` is `@StateObject` in ContentView
   - Make sure it's `@ObservedObject` in other views
   - Try adding `.id(subscriptionManager.subscriptionStatus)` to fullScreenCover

4. **Force dismiss in PaywallView**
   ```swift
   // In PaywallView purchase completion
   if subscriptionManager.isSubscribed {
       dismiss()  // Explicitly dismiss
   }
   ```

---

### 🚫 Issue: App crashes when showing paywall

**Symptoms:**
- App opens, then immediately crashes
- Console shows error about SubscriptionManager

**Solutions:**

1. **Check iOS version**
   - StoreKit 2 requires iOS 15.0+
   - Your app targets iOS 17.0+, so should be fine
   - But verify deployment target is set correctly

2. **Verify StoreKit is imported**
   ```swift
   // At top of SubscriptionManager.swift
   import StoreKit  // Must be present
   ```

3. **Check for force-unwrapping**
   - Look for `!` in SubscriptionManager
   - Should use optional binding or `guard let` instead

4. **View crash logs**
   - Xcode → Window → Devices and Simulators
   - Select device → View Device Logs
   - Look for your app's crash report

---

### 🚫 Issue: "Restore Purchases" doesn't find anything

**Symptoms:**
- User taps "Restore Purchases"
- Shows error: "No previous purchases found"
- But they definitely purchased

**Solutions:**

1. **Check if purchase actually completed**
   - In testing, some purchases might not commit
   - Try making a fresh purchase first

2. **Verify same Apple ID**
   - User must be signed into same Apple ID that made purchase
   - Settings → [Name] → View Apple ID

3. **Check transaction entitlements**
   ```swift
   // In SubscriptionManager.updateSubscriptionStatus()
   for await result in Transaction.currentEntitlements {
       // This should find active transactions
       // Add print() statements to debug
   }
   ```

4. **Sandbox testing issues**
   - Sandbox accounts can be flaky
   - Try deleting and recreating sandbox tester
   - Or test with StoreKit configuration instead

---

### 🚫 Issue: Subscription status shows "unknown"

**Symptoms:**
- Settings shows "Checking..." or "Unknown"
- Status never updates
- App seems to work but state is wrong

**Solutions:**

1. **Wait a few seconds**
   - First load can take 2-3 seconds
   - StoreKit needs time to check entitlements

2. **Check async tasks are completing**
   ```swift
   // In SubscriptionManager.init()
   Task {
       await loadProducts()        // Should complete
       await updateSubscriptionStatus()  // Should complete
   }
   ```
   Add `print()` statements to verify these run.

3. **Verify network connection**
   - Real App Store needs internet
   - StoreKit configuration doesn't
   - Check airplane mode is off

4. **Check for @MainActor issues**
   ```swift
   @MainActor
   class SubscriptionManager: ObservableObject {
       // All published properties need @MainActor
   }
   ```

---

### 🚫 Issue: Purchase works but app forgets on relaunch

**Symptoms:**
- User purchases successfully
- App works fine
- Close and reopen app → Shows paywall again

**Solutions:**

1. **Check init() calls updateSubscriptionStatus**
   ```swift
   init() {
       updateListenerTask = listenForTransactions()
       
       Task {
           await loadProducts()
           await updateSubscriptionStatus()  // MUST be here
       }
   }
   ```

2. **Verify transaction listener is running**
   ```swift
   private func listenForTransactions() -> Task<Void, Never> {
       return Task.detached { [weak self] in
           for await result in Transaction.updates {
               // Should update status when transactions change
           }
       }
   }
   ```

3. **Check for state being reset**
   - Make sure `subscriptionManager` is `@StateObject` not `@State`
   - Should only be created once per app session

---

### 🚫 Issue: "Purchase failed verification"

**Symptoms:**
- Purchase completes in StoreKit
- But app shows error
- Console: "Transaction verification failed"

**Solutions:**

1. **Check verification logic**
   ```swift
   private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
       switch result {
       case .unverified:
           throw PurchaseError.verificationFailed
       case .verified(let safe):
           return safe  // Should return this
       }
   }
   ```

2. **StoreKit configuration testing**
   - Local testing should always verify successfully
   - If failing, StoreKit config might be corrupted
   - Delete and recreate the .storekit file

3. **Production environment**
   - Verification failures can happen with jailbroken devices
   - Or if App Store receipt is invalid
   - This is rare and usually means fraud attempt

---

### 🚫 Issue: Links to Privacy Policy don't work

**Symptoms:**
- Tap "Privacy Policy" or "Terms of Service"
- Nothing happens or error shown

**Solutions:**

1. **Check URLs are valid**
   ```swift
   // In PaywallView.swift
   Link("Privacy Policy", destination: URL(string: "https://yourwebsite.com/privacy-policy.html")!)
   ```
   Replace `yourwebsite.com` with real URL!

2. **Test URL in Safari**
   - Copy URL from code
   - Paste into Safari
   - Should load successfully

3. **Check HTTPS**
   - URLs must use HTTPS (not HTTP)
   - App Transport Security requires this

4. **Remove force-unwrap if URL might be invalid**
   ```swift
   if let url = URL(string: "your-url-here") {
       Link("Privacy Policy", destination: url)
   }
   ```

---

### 🚫 Issue: Price shows $0.99 in code but different in App Store

**Symptoms:**
- Paywall says "$0.99/month"
- But App Store shows different price

**Solutions:**

1. **Check App Store Connect pricing**
   - Log into App Store Connect
   - Your App → In-App Purchases
   - Click on subscription
   - Check Subscription Pricing
   - Should be $0.99 in Tier 1

2. **Different regions have different prices**
   - $0.99 in USA
   - €0.99 in Europe
   - £0.99 in UK
   - Apple auto-converts

3. **Use displayPrice from Product**
   ```swift
   // In PaywallView
   Text("then \(subscriptionManager.displayPrice)/month")
   ```
   This shows localized price from App Store!

---

### 🚫 Issue: Free trial not showing up

**Symptoms:**
- Purchase flow doesn't mention free trial
- User charged immediately

**Solutions:**

1. **Check introductory offer in StoreKit config**
   ```json
   "introductoryOffer" : {
     "paymentMode" : "free",
     "subscriptionPeriod" : "P1W",
     "numberOfPeriods" : 1
   }
   ```
   - `P1W` = 1 week (7 days)
   - `paymentMode` must be `"free"`

2. **Check App Store Connect**
   - Subscription → Introductory Offers
   - Should show "7 Days Free"
   - Status should be "Ready to Submit" or "Approved"

3. **User eligibility**
   - Free trial only available to NEW subscribers
   - If user previously subscribed, no trial
   - If user cancelled and resubscribing, no trial
   - This is Apple's rule, not your code

---

### 🚫 Issue: Settings show subscription status but main app still shows paywall

**Symptoms:**
- Settings → Subscription shows "Active"
- But main app shows paywall on launch

**Solutions:**

1. **Check ContentView logic**
   ```swift
   .onAppear {
       // This might be running before subscription loads
       if !subscriptionManager.isSubscribed {
           showPaywall = true
       }
   }
   ```

2. **Add delay or check for unknown status**
   ```swift
   .onAppear {
       // Don't show paywall if still checking
       if subscriptionManager.subscriptionStatus == .notSubscribed ||
          subscriptionManager.subscriptionStatus == .expired {
           showPaywall = true
       }
   }
   ```

3. **Force refresh on appear**
   ```swift
   .onAppear {
       Task {
           await subscriptionManager.updateSubscriptionStatus()
       }
   }
   ```

---

### 🚫 Issue: App rejected by App Review

**Reason: Subscription terms not clear**

**Solution:**
- ✅ Price is shown on paywall ($0.99/month)
- ✅ Free trial mentioned (7 days free)
- ✅ Auto-renewal mentioned in fine print
- ✅ Links to Privacy Policy and Terms
- All of this is already implemented!

**Reason: No restore purchases**

**Solution:**
- ✅ "Restore Purchases" button on paywall
- Already implemented!

**Reason: Privacy Policy URL doesn't work**

**Solution:**
- Update URL in PaywallView.swift
- Make sure it's publicly accessible
- Test in Safari before resubmitting

**Reason: Subscription not found in App Store Connect**

**Solution:**
- Make sure subscription is submitted for review
- Not just saved as draft
- Product ID matches code exactly

---

## Debugging Tips

### Enable StoreKit Logging

Add to your scheme's Environment Variables:
```
Name: StoreKitLogging
Value: 1
```

This shows detailed StoreKit logs in console.

### Add Debug Prints

In SubscriptionManager:
```swift
func updateSubscriptionStatus() async {
    print("🔍 Checking subscription status...")
    
    var status: SubscriptionStatus = .notSubscribed
    
    for await result in Transaction.currentEntitlements {
        print("🔍 Found transaction...")
        // ... rest of code
    }
    
    print("🔍 Final status: \(status)")
    self.subscriptionStatus = status
}
```

### Test State Changes

Add this to ContentView:
```swift
.onChange(of: subscriptionManager.subscriptionStatus) { old, new in
    print("🔄 Status changed from \(old) to \(new)")
    print("   isSubscribed: \(subscriptionManager.isSubscribed)")
    print("   showPaywall: \(showPaywall)")
}
```

---

## Still Having Issues?

1. **Check the full setup guide**
   - Read `IAP_SETUP_GUIDE.md` completely
   - Make sure all steps are completed

2. **Verify your checklist**
   - Review `PRE_SUBMISSION_CHECKLIST.md`
   - Check off each item

3. **Test with StoreKit configuration first**
   - Easier than sandbox testing
   - More reliable
   - No internet needed

4. **Check Apple's StoreKit documentation**
   - [developer.apple.com/storekit](https://developer.apple.com/storekit)
   - Search for your specific error message

5. **Review transaction logs**
   - Xcode Console
   - Look for StoreKit errors
   - Enable StoreKit logging (see above)

---

## Emergency Bypass (Testing Only!)

If you need to test the app without paywall during development:

```swift
// In ContentView.swift
.onAppear {
    // REMOVE THIS BEFORE SUBMITTING!
    #if DEBUG
    showPaywall = false  // Skip paywall in debug builds
    #else
    if !subscriptionManager.isSubscribed {
        showPaywall = true
    }
    #endif
}
```

**⚠️ WARNING:** Remove this before submitting to App Store!

---

## Contact Apple Developer Support

If you've tried everything:

1. Go to [developer.apple.com/contact](https://developer.apple.com/contact)
2. Select "App Store Connect and Commerce"
3. Choose "In-App Purchase and Subscriptions"
4. Describe your issue
5. Include:
   - Product ID
   - App ID
   - Error messages
   - What you've tried
