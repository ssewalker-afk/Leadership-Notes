# Leadership Notes

A native SwiftUI app for iOS/iPadOS — Private on-device coaching journal for tracking employee interactions, incidents, and important dates.

## Overview

Leadership Notes is a complete rebuild of the React-based web app as a **native Swift application** using SwiftUI. All data is stored locally on device using UserDefaults with no cloud sync or external connections.

## Features

### ⚡ Quick Entry
- Select person and category
- Track sub-types (Late/Early, No Notice/Short Notice, etc.)
- Log duration in minutes
- Record whether notice was given
- Add follow-up reminders
- Include optional notes

### 📋 History
- View all entries in chronological order
- Filter by person, category, or team
- Search across all entry fields
- Expand entries to see full details
- Edit or delete entries
- Visual category badges with custom colors

### 📊 Reports
- Set custom date ranges
- Filter by person or team
- View summary statistics
- Heat map showing category frequency
- Generate text reports
- Email reports directly from the app
- Preview reports before sending

### 👥 People Management
- Add/remove team members
- Assign to teams
- Track important dates (birthdays, certifications, etc.)
- Set reminders for important dates (48 hours, 1 week, 2 weeks)
- Recurring yearly dates
- View entry count per person

### ⚙️ Settings

#### General
- Three themes: Light, Dark, and Rainbow (Neon)
- Configure duration max and increment
- Customize follow-up options

#### Categories
- 9 default categories (Arrival, Lunch, Early Out, No Show, etc.)
- Add custom categories
- Configure emoji icon and color
- Enable/disable sub-types, duration, and notice tracking
- Define custom sub-type options

#### Teams
- Manage up to 5 teams
- Activate/deactivate teams
- Rename teams
- See people count per team

#### Data
- **Backup**: Export all data as JSON
- **Import**: Restore from backup
- **Archive**: Email and remove entries by year
- **Nuclear Reset**: Delete everything

### 🔔 Reminders
- Automatic reminders for upcoming important dates
- Follow-up reminders for entries
- Shows days until due
- Displayed on entry screen

## Technical Details

### Architecture
- **SwiftUI** for declarative UI
- **Observable objects** for state management
- **UserDefaults** for persistence
- **Native pickers and date selectors**
- **Share sheet** for export
- **Mail composer** integration

### Files Structure
```
LeadershipNotesApp.swift    - App entry point
ContentView.swift            - Main navigation and layout
Models.swift                 - Data models and themes
AppStore.swift               - State management and persistence
EntryView.swift              - Quick entry form
HistoryView.swift            - Entry list and filtering
ReportsView.swift            - Analytics and reporting
PeopleView.swift             - People and important dates
SettingsView.swift           - App configuration
SharedComponents.swift       - Reusable UI components
```

### Data Models

**Entry**
- Person reference
- Category with optional sub-type
- Duration (minutes)
- Notice given (yes/no)
- Follow-up with due date
- Notes
- Timestamp

**Person**
- Name
- Team assignment
- Important dates array

**Category**
- Label and emoji icon
- Color
- Sub-types configuration
- Duration/notice toggles

**Team**
- Name
- Active status

## Privacy

✅ **100% On-Device**
- All data stored in UserDefaults
- No network requests
- No cloud sync
- No analytics or tracking
- Export/import for manual backup

## Setup

1. Open in Xcode 15 or later
2. Select your target device (iPhone/iPad)
3. Build and run (⌘R)

## Requirements

- iOS 17.0+ or iPadOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Usage Tips

### Quick Workflow
1. Add your team members in **People**
2. Customize categories in **Settings** if needed
3. Use **Entry** tab for quick logging
4. Review **History** regularly
5. Generate **Reports** for documentation
6. Set **Important Dates** for proactive reminders

### Best Practices
- Log entries immediately for accuracy
- Use notes field for context
- Set follow-ups for items requiring action
- Export backups regularly
- Archive old entries annually
- Email reports before archiving

### Themes
- **Light**: Professional look for well-lit environments
- **Dark**: Reduces eye strain in dim lighting
- **Rainbow (Neon)**: High-contrast modern aesthetic

## Advantages Over Web Version

✅ Native iOS/iPadOS experience
✅ Better performance
✅ Offline-first by design
✅ Haptic feedback
✅ System font support
✅ Respects system accessibility settings
✅ Native date/time pickers
✅ Share sheet integration
✅ No browser required
✅ Can run on iPad in split view

## Future Enhancements

Possible additions:
- iCloud sync (optional)
- Apple Watch companion app
- Widgets for quick entry
- Siri shortcuts
- Face ID/Touch ID protection
- PDF export
- Charts and graphs
- Multi-language support
- Export to CSV
- Dark mode icon variants

## License

This is a rebuild of a private coaching journal app. Use at your own discretion for legitimate employee management purposes in accordance with local employment laws and company policies.

---

**Built with ❤️ using SwiftUI**
