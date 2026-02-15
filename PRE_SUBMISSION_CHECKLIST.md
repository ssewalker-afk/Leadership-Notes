# Pre-Submission Checklist

## Code Changes
- [ ] Updated product ID in `SubscriptionManager.swift` to match your bundle identifier
- [ ] Updated Privacy Policy URL in `PaywallView.swift`
- [ ] Updated Terms of Service URL in `PaywallView.swift`
- [ ] Tested app locally with StoreKit configuration file
- [ ] Verified paywall appears on first launch
- [ ] Verified paywall dismisses after "purchase"
- [ ] Verified subscription status shows correctly in Settings

## App Store Connect
- [ ] Created subscription group
- [ ] Created monthly subscription product ($0.99/month)
- [ ] Product ID in App Store Connect matches code
- [ ] Added 7-day free trial introductory offer
- [ ] Added English localization with display name and description
- [ ] Submitted subscription for review

## Legal Requirements
- [ ] Privacy Policy is published and accessible at the URL in code
- [ ] Terms of Service is published and accessible at the URL in code
- [ ] Both documents mention subscription terms
- [ ] Both documents mention auto-renewal
- [ ] Both documents mention how to cancel

## Testing
- [ ] Tested on simulator with StoreKit configuration
- [ ] Tested "Start Free Trial" flow
- [ ] Tested "Restore Purchases" button
- [ ] Tested app behavior when subscribed
- [ ] Tested app behavior when not subscribed
- [ ] Tested subscription status display in Settings
- [ ] Tested "Manage Subscription" link (opens App Store)
- [ ] (Optional) Tested on physical device with sandbox account

## App Store Metadata
- [ ] App description mentions subscription pricing
- [ ] App description mentions 7-day free trial
- [ ] App description mentions auto-renewal
- [ ] Screenshot set includes paywall screen (optional but recommended)
- [ ] App Review notes explain why subscription is required

## Compliance
- [ ] Subscription terms clearly displayed on paywall
- [ ] Price displayed before purchase ($0.99/month)
- [ ] Free trial duration displayed (7 days)
- [ ] Link to Privacy Policy visible on paywall
- [ ] Link to Terms of Service visible on paywall
- [ ] "Restore Purchases" button is easily accessible
- [ ] No mention of other payment methods (Apple policy)

## Final Checks
- [ ] App builds without errors
- [ ] No hardcoded test data or debug code
- [ ] StoreKit configuration file included in project
- [ ] All code properly committed to version control
- [ ] Archive created successfully
- [ ] App icons and assets all present
- [ ] Version number and build number incremented

## App Review Notes (Include These)

**For App Review Team:**

"Leadership Notes is a professional coaching documentation app for managers and team leaders. The subscription is required because:

1. The app provides unlimited entry storage and document generation
2. Professional reporting features for workplace documentation
3. Private, on-device data management with export capabilities
4. Ongoing development and support costs

Subscription Details:
- 7-day free trial (clearly displayed on paywall)
- $0.99/month after trial
- Auto-renewable subscription
- Cancel anytime via iOS Settings

Test Account (if needed):
- Email: [your sandbox tester email]
- Password: [your sandbox tester password]

Privacy Policy: [your URL]
Terms of Service: [your URL]

Users can restore purchases using the 'Restore Purchases' button on the paywall screen. Subscription status is displayed in Settings → General."

---

## If App Review Rejects

Common rejection reasons and fixes:

### "Subscription not clearly disclosed"
- ✅ Already fixed: Price and trial shown on paywall
- ✅ Already fixed: Terms displayed before purchase
- ✅ Already fixed: Links to legal documents

### "Must offer restore purchases"
- ✅ Already implemented: "Restore Purchases" button on paywall

### "App has no free features"
- Response: "This is a professional workplace documentation tool. The subscription enables unlimited storage, professional reports, and data export features essential to the app's core functionality."

### "Privacy policy not accessible"
- Fix: Ensure your privacy policy URL works and loads correctly
- Verify URL in PaywallView.swift is correct

### "Cannot find subscription in App Store Connect"
- Fix: Ensure subscription is submitted for review (not just saved as draft)
- Verify product ID matches exactly

---

## Post-Approval Steps

After app is approved and live:

- [ ] Verify subscription works with real App Store
- [ ] Monitor crash reports
- [ ] Monitor subscription metrics in App Store Connect
- [ ] Respond to user reviews
- [ ] Set up App Analytics to track conversions
- [ ] Consider A/B testing paywall copy (future)

---

## Support Resources

If users report subscription issues:

1. Direct them to iOS Settings → [Your Name] → Subscriptions
2. Or open App Store → Account → Subscriptions
3. For refunds: reportaproblem.apple.com
4. Check transaction logs in App Store Connect

## Monitoring

Check regularly:
- App Store Connect → Sales and Trends
- App Store Connect → Payments and Financial Reports
- App Analytics → Subscriptions
- Reviews and ratings
