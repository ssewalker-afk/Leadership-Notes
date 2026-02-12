# App Store Submission Checklist

## ✅ Pre-Submission Checklist

Use this checklist to ensure you're ready to submit Leadership Notes to the App Store.

---

## 🔧 1. Update Placeholder Information

### In Your Code

- [ ] Replace `YOUR-USERNAME` in `SettingsView.swift` (3 locations)
  - Support URL line
  - Privacy Policy URL line
  - Terms of Service URL line

### In Your HTML Files

- [ ] Replace `support@example.com` in:
  - [ ] `support.html` (multiple locations)
  - [ ] `privacy-policy.html`
  - [ ] `terms-of-service.html`

---

## 🌐 2. Publish to GitHub Pages

- [ ] Push all HTML files to GitHub
  ```bash
  git add index.html support.html privacy-policy.html terms-of-service.html
  git commit -m "Add support page and legal documents"
  git push origin main
  ```

- [ ] Make repository public (Settings → Danger Zone → Change visibility)

- [ ] Enable GitHub Pages (Settings → Pages → Deploy from branch → main → / root → Save)

- [ ] Wait 2-3 minutes for deployment

- [ ] Verify all URLs work:
  - [ ] Landing page: `https://YOUR-USERNAME.github.io/leadership-notes/`
  - [ ] Support: `https://YOUR-USERNAME.github.io/leadership-notes/support.html`
  - [ ] Privacy: `https://YOUR-USERNAME.github.io/leadership-notes/privacy-policy.html`
  - [ ] Terms: `https://YOUR-USERNAME.github.io/leadership-notes/terms-of-service.html`

---

## 📱 3. App Store Connect Setup

### App Information

- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Create new app (if not already created)
- [ ] Fill in basic information:
  - [ ] App name: "Leadership Notes"
  - [ ] Subtitle: "Private Employee Coaching Log" (or your choice)
  - [ ] Primary Language: English
  - [ ] Bundle ID: (your bundle identifier)
  - [ ] SKU: (your internal tracking ID)

### URLs

- [ ] Add Support URL: `https://YOUR-USERNAME.github.io/leadership-notes/support.html`
- [ ] Add Privacy Policy URL: `https://YOUR-USERNAME.github.io/leadership-notes/privacy-policy.html`
- [ ] Add Marketing URL (optional): `https://YOUR-USERNAME.github.io/leadership-notes/`

### Categories

- [ ] Primary Category: **Business** or **Productivity**
- [ ] Secondary Category (optional): **Utilities** or **Lifestyle**

---

## 📸 4. App Store Assets

### Screenshots Required

**iPhone (6.7" Display)** - iPhone 15 Pro Max, 14 Pro Max
- [ ] 3-10 screenshots at 1290 × 2796 pixels

**iPhone (6.5" Display)** - iPhone 11 Pro Max, XS Max
- [ ] 3-10 screenshots at 1242 × 2688 pixels

**iPad Pro (12.9" Display)** - 3rd, 4th, 5th gen
- [ ] 3-10 screenshots at 2048 × 2732 pixels

### App Icon

- [ ] 1024 × 1024 pixels
- [ ] PNG format
- [ ] No transparency
- [ ] No rounded corners (Apple adds them)

### App Preview Video (Optional)

- [ ] 15-30 second video showing app features
- [ ] Same dimensions as screenshots

---

## 📝 5. App Description

### What You'll Need

- [ ] **Description** (4000 character limit)
  - Brief overview
  - Key features
  - Benefits
  - Privacy focus

- [ ] **Keywords** (100 character limit, comma-separated)
  - Suggested: `leadership,employee,coaching,notes,journal,management,hr,team,documentation,private`

- [ ] **Promotional Text** (170 character limit, can be updated anytime)
  - Example: "Track employee interactions privately. No cloud sync, no data collection. Everything stays on your device. Perfect for managers and team leaders."

- [ ] **What's New** (for future updates, 4000 character limit)

---

## 💰 6. Pricing & Availability

### Subscription Setup

- [ ] Set up In-App Purchase:
  - [ ] Product ID: (e.g., `com.yourcompany.leadershipnotes.yearly`)
  - [ ] Type: Auto-Renewable Subscription
  - [ ] Duration: 1 Year
  - [ ] Price: $1.99 USD
  - [ ] Free Trial: 7 days

- [ ] Create Subscription Group
- [ ] Add subscription localizations and descriptions
- [ ] Submit for review

### Pricing

- [ ] Select countries/regions for availability
- [ ] Choose pricing tier or set custom pricing
- [ ] Set pre-order availability (optional)

---

## 🔐 7. App Review Information

### Contact Information

- [ ] First Name
- [ ] Last Name
- [ ] Phone Number
- [ ] Email Address

### Demo Account (if needed)

- [ ] Demo username
- [ ] Demo password
- [ ] Instructions for reviewer

### Notes for Reviewer

Example:
```
Leadership Notes is a private, on-device journal for employee documentation.
No account is required. All data is stored locally using UserDefaults.
The app includes a 7-day free trial, then $1.99/year subscription.

Test subscription: Use TestFlight sandbox accounts for testing the subscription.

Privacy: We do not collect any user data. Everything stays on device.
```

---

## ⚖️ 8. Legal & Compliance

- [ ] Export Compliance: Does your app use encryption?
  - [ ] If yes, register for export compliance
  - [ ] If standard iOS encryption only, select "No"

- [ ] Content Rights: Do you have rights to all content?
  - [ ] Yes (it's your original work)

- [ ] Age Rating Questionnaire
  - [ ] Complete honestly
  - [ ] Likely rating: 4+ or 9+

- [ ] Government End User Notice (if applicable)

---

## 🧪 9. Testing

### Before Submitting

- [ ] Test on multiple devices (iPhone and iPad)
- [ ] Test all features thoroughly
- [ ] Test subscription flow (using sandbox accounts)
- [ ] Test on iOS 17.0+ (minimum supported version)
- [ ] Check for crashes or bugs
- [ ] Verify all links in Settings work
- [ ] Test backup/export/import features
- [ ] Test in both Light and Dark mode
- [ ] Test all three app themes

### TestFlight (Recommended)

- [ ] Upload build to TestFlight
- [ ] Add internal testers
- [ ] Add external testers (optional)
- [ ] Collect feedback
- [ ] Fix any reported issues

---

## 📋 10. Final Checklist

### Code

- [ ] App version number set correctly
- [ ] Bundle version incremented
- [ ] All placeholders replaced
- [ ] No debug code left in
- [ ] All console logs removed (or set to release mode only)
- [ ] Proper error handling
- [ ] Code signed with distribution certificate

### Xcode

- [ ] Archive created successfully
- [ ] No warnings or errors
- [ ] Proper provisioning profile selected
- [ ] Correct Bundle ID
- [ ] Version and build numbers correct

### App Store Connect

- [ ] All required fields filled
- [ ] Screenshots uploaded
- [ ] App icon uploaded
- [ ] Description proofread
- [ ] URLs verified and working
- [ ] Pricing set
- [ ] Subscription configured
- [ ] Review information complete

---

## 🚀 11. Submit for Review

- [ ] Click "Submit for Review" in App Store Connect
- [ ] Wait for "Waiting for Review" status
- [ ] Review typically takes 24-48 hours (but can take up to 7 days)
- [ ] Respond promptly to any App Review questions

---

## 📬 12. Post-Submission

### If Approved ✅

- [ ] App goes live automatically (or at scheduled date)
- [ ] Share on social media
- [ ] Tell friends and colleagues
- [ ] Monitor reviews and ratings
- [ ] Respond to user feedback

### If Rejected ❌

- [ ] Read rejection reason carefully
- [ ] Address all issues mentioned
- [ ] Update app if needed
- [ ] Resubmit with explanation
- [ ] Use App Review Board if you disagree with rejection

---

## 📊 13. Post-Launch

- [ ] Monitor crash reports (Xcode Organizer)
- [ ] Check subscription analytics
- [ ] Respond to user reviews
- [ ] Plan updates and improvements
- [ ] Update legal documents as needed

---

## 📞 Need Help?

- [Apple Developer Forums](https://developer.apple.com/forums/)
- [App Store Connect Help](https://developer.apple.com/support/app-store-connect/)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

**Good luck with your submission!** 🎉
