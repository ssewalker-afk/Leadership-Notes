# Quick Reference Card - Coaching Log

## 🎯 Main Features at a Glance

### 📝 Creating Entries
- **New Entry**: Tap + button → New Entry
- **From Template**: Tap + → New Entry → Use Template
- **Add Photos**: Use Photos Picker (max 5 images)
- **Set Follow-up**: Toggle follow-up switch, choose date
- **Tags**: Comma-separated (e.g., "urgent, performance, review")

### 👥 Managing Employees
- **New Employee**: Tap + → New Employee
- **Profile Photo**: Tap photo area in employee form
- **View Profile**: Tap employee name in entry
- **Important Dates**: Toggle to set birthday/hire date
- **Employee Notes**: Edit in profile view

### 🗂️ Using Templates
- **Create Template**: Settings → Manage Templates → +
- **Use Template**: When creating entry → Use Template button
- **Delete Template**: In template list → tap trash icon

### 🔍 Finding Entries
- **Search**: Pull down to reveal search bar
- **Filter**: Tap + → Filters
  - By Category
  - By Employee
- **Clear Filters**: In filter view → Clear All Filters

### 🗑️ Bulk Operations
- **Select Multiple**: Tap + → Select Multiple
- **Select/Deselect**: Tap entries to toggle
- **Select All**: Tap "Select All" in toolbar
- **Delete Selected**: Tap trash icon → Confirm

### 📊 Reports & Export
- **Change Time Range**: Use segmented control (Week/Month/Quarter/Year/All)
- **Export CSV**: Tap share icon → Export as CSV
- **Export PDF**: Tap share icon → Export as PDF
- **Share**: After export → Choose sharing method

### 🔔 Notifications
- **Enable**: Settings → Notifications toggle
- **Follow-up Timing**: Settings → adjust days before
- **Birthday Timing**: Settings → adjust days before
- **Anniversary Timing**: Settings → adjust days before
- **Permissions**: iOS will prompt on first use

### 🔒 Security
- **Set PIN**: Settings → PIN Protection toggle
- **Change PIN**: Settings → Change PIN
- **Remove PIN**: Settings → Toggle off PIN Protection

### 💻 iPad Features
- **Split View**: Automatic on iPad
- **Resize Panels**: Drag divider
- **Select Entry**: Tap in sidebar to view in detail panel
- **All Features**: Same as iPhone, optimized layout

---

## ⌨️ Keyboard Shortcuts (Planned)

### iPad Shortcuts
- **⌘N**: New Entry
- **⌘⇧N**: New Employee
- **⌘F**: Search
- **⌘⇧E**: Export
- **⌘⇧S**: Settings
- **Delete**: Delete selected (in bulk mode)
- **⌘A**: Select All (in bulk mode)

---

## 🎨 UI Elements Guide

### Entry Categories & Colors
- **Performance** - Purple (`#7C3AED`)
- **Coaching** - Cyan (`#22D3EE`)
- **Recognition** - Green (`#10B981`)
- **Concern** - Red (`#EF4444`)
- **Goal** - Orange (`#F59E0B`)
- **1:1 Meeting** - Pink (`#EC4899`)
- **Feedback** - Violet (`#8B5CF6`)
- **Training** - Blue (`#3B82F6`)
- **Other** - Gray (`#6B7280`)

### Status Indicators
- 🔔 **Bell Icon** - Has pending follow-up
- ✅ **Check Icon** - Completed follow-up
- 📌 **Pin Icon** - Pinned note
- ☑️ **Checkmark Circle** - Selected (bulk mode)

---

## 📁 Data Organization

### Entry Fields
- **Required**: Title, Content
- **Optional**: Employee, Photos, Tags, Follow-up
- **Auto-filled**: Date, Created/Modified timestamps

### Employee Fields
- **Required**: First Name, Last Name
- **Optional**: Email, Phone, Job Title, Department, Hire Date, Birthday, Photo, Notes

### Template Fields
- **Required**: Name, Content
- **Auto-filled**: Category, Created Date

---

## 🔄 Data Flow

### Creating Entry with Notification
1. Create entry with follow-up date
2. Entry saved to SwiftData
3. Notification automatically scheduled
4. Reminder arrives N days before

### Using Template
1. Create template in Settings
2. Tap "Use Template" in new entry
3. Content and category pre-filled
4. Edit as needed
5. Save entry

### Bulk Delete
1. Enter selection mode
2. Select entries
3. Confirm delete
4. Entries removed from SwiftData
5. Related notifications cancelled

### Export Flow
1. Filter data in Reports
2. Choose export format
3. File generated in temp directory
4. Share sheet appears
5. Send via chosen method
6. File auto-deleted by iOS later

---

## ⚙️ Settings Structure

### Security
- PIN Protection (On/Off)
- Change PIN

### Notifications
- Enable Notifications (On/Off)
- Follow-up Reminder Days (0-30)
- Birthday Reminder Days (0-30)
- Anniversary Reminder Days (0-30)

### Data Management
- Manage Templates

### App Information
- About (Version, features, credits)

---

## 🐛 Common Issues & Solutions

### "Notifications not appearing"
- ✅ Check: Settings app → Coaching Log → Allow Notifications
- ✅ Check: In-app Settings → Notifications enabled
- ✅ Ensure: Date is in the future
- ✅ Try: Re-save entry to reschedule

### "Can't export files"
- ✅ Ensure: You have entries in selected time range
- ✅ Try: Different time range filter
- ✅ Check: iOS storage space available

### "Template not pre-filling"
- ✅ Ensure: Template has content
- ✅ Try: Recreate template
- ✅ Check: You selected template after tapping "Use Template"

### "iPad not showing split view"
- ✅ Check: Device is iPad (not iPhone)
- ✅ Ensure: Running in full screen
- ✅ Try: Rotate device
- ✅ Note: Works in all orientations

### "Bulk delete not working"
- ✅ Ensure: Entries are selected (checkmarks visible)
- ✅ Try: Select All button
- ✅ Confirm: In delete dialog

---

## 📱 Device-Specific Features

### iPhone
- Tab-based navigation
- Full-screen views
- Pull-to-refresh
- Swipe gestures

### iPad
- Split-view navigation
- Sidebar for app sections
- Resizable panels
- Master-detail for entries
- Keyboard shortcuts (planned)
- Drag and drop (future)

---

## 🎯 Best Practices

### For Optimal Performance
- Delete old entries periodically (or archive feature coming)
- Use templates for common scenarios
- Set realistic reminder timing (not too far in advance)
- Regular exports for backup

### For Team Management
- Add all employees first
- Use consistent category naming
- Tag entries for easy searching
- Set follow-ups for important items
- Review reports monthly

### For Data Safety
- Export regularly (CSV/PDF)
- Enable PIN if device is shared
- Keep iOS updated for latest security

---

## 📞 Support

### Documentation
- **README.md** - Feature overview
- **IMPLEMENTATION.md** - Technical details
- **SUMMARY.md** - Feature completion status
- **InfoPlistGuide.swift** - Setup instructions

### Version
- **Current**: 1.0.0
- **Platform**: iOS 17.0+, iPadOS 17.0+
- **Framework**: SwiftUI + SwiftData

---

## 🚀 Quick Start Workflow

1. **First Launch**
   - Grant notification permission (optional)
   - Set PIN (optional)

2. **Add Employees**
   - Tap + → New Employee
   - Fill in details
   - Add photo (optional)

3. **Create Entry**
   - Tap + → New Entry
   - Select employee
   - Choose category
   - Write content
   - Set follow-up (optional)
   - Add photos/tags (optional)

4. **Use Template (Optional)**
   - Settings → Manage Templates → Create
   - When creating entry → Use Template

5. **Review Reports**
   - Navigate to Reports tab
   - Change time range
   - Export as needed

6. **Configure Settings**
   - Adjust notification timing
   - Set up security
   - Manage templates

---

## 💡 Pro Tips

- Use **templates** for weekly 1:1 meetings
- Set **follow-ups** for performance reviews (30/60/90 days)
- **Export** monthly reports for records
- Use **tags** for tracking initiatives (#q1-goals, #training-program)
- Enable **notifications** so you never miss important dates
- On **iPad**, keep entry list visible while reviewing details
- Use **bulk delete** to clean up old test entries
- **Pin** important reference notes

---

**Happy Coaching! 📊✨**
