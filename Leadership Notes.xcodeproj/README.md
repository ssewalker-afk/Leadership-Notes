# Coaching Log

A comprehensive employee coaching and management app for iOS and iPadOS, built with SwiftUI and SwiftData.

## Overview

Coaching Log is designed for managers and team leaders to track employee interactions, performance notes, goals, and important events. All data is stored locally on the device for maximum privacy and offline functionality.

## Features

### 🗂️ Coaching Log (Main Dashboard)
- Create and manage coaching entries with rich text, photos, and tags
- **Use templates** for quick entry creation
- Categorize entries (Performance, Coaching, Recognition, Concern, Goal, 1:1 Meeting, Feedback, Training)
- Set follow-up reminders with push notifications
- Search and filter entries by employee, category, or keywords
- **Bulk selection and deletion** of entries
- View entry history with detailed records
- **iPad split-view layout** for enhanced productivity

### 👥 Employee Management
- Comprehensive employee profiles with contact information
- Track job titles, departments, and hire dates
- Store profile photos
- Manage employee-specific notes
- Track birthdays and work anniversaries with notifications
- View employee activity history

### 📊 Reports & Analytics
- Visual data representations using Swift Charts
- Entry trends over time
- Category distribution charts
- Employee activity rankings
- Customizable time ranges (week, month, quarter, year, all time)
- **Export to CSV and PDF** with formatted reports
- Share exports via system share sheet

### 📝 Personal Notes
- Quick note-taking for personal reminders
- Pin important notes
- Search functionality
- Edit and organize notes

### 🔔 Notifications & Reminders
- **Local push notifications** for all reminders
- Follow-up reminders for coaching entries
- Birthday notifications (customizable advance notice)
- Work anniversary alerts (customizable advance notice)
- Customizable reminder timing
- Automatic notification scheduling

### 📄 Templates
- Create reusable entry templates
- Pre-fill common coaching scenarios
- Category-specific templates
- Manage templates from settings
- Quick template selection when creating entries

### 🔒 Security
- Optional PIN protection
- All data stored locally using SwiftData
- No cloud sync or external data sharing
- Complete privacy and offline functionality

### 💻 iPad Optimization
- **Split-view navigation** for multitasking
- Master-detail layout for entries
- Optimized sidebar navigation
- Responsive design adapts to screen size
- Full feature parity with iPhone

### ⚙️ Settings
- Configure notification preferences
- Set and manage PIN protection
- Customize reminder timings
- Manage entry templates
- Request notification permissions

## Design

### Color Scheme
The app uses a modern dark theme with:
- **Background Colors**: Dark blues and grays (#0b1220, #111827, #11182B)
- **Text Colors**: Light shades (#f8fafc, #cbd5e1) with muted tones (#94a3b8)
- **Accent Colors**: Vibrant purples (#7C3AED, #5B21B6), pink (#EC4899), and cyan (#22D3EE)

### Typography
- Primary font: System font (Inter-inspired) with clean, modern styling
- Bold headings and regular body text
- Consistent sizing and weight throughout

### UI Components
- Card-based layouts with rounded corners
- Gradient accents for buttons and highlights
- SF Symbols for consistent iconography
- Smooth transitions and animations

## Technical Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Charts**: Swift Charts
- **Photo Handling**: PhotosUI
- **Notifications**: UserNotifications
- **PDF Generation**: PDFKit & UIGraphicsPDFRenderer
- **Sharing**: UIActivityViewController
- **Minimum Target**: iOS 17.0, iPadOS 17.0

## Architecture

### Models
- `Employee`: Employee information and relationships
- `CoachingEntry`: Coaching log entries with rich metadata
- `PersonalNote`: Personal note-taking
- `Goal`: Employee goals with progress tracking
- `EntryTemplate`: Reusable entry templates
- `Reminder`: Follow-up reminders

### Views
- **Main Views**: CoachingLogView, NotesView, ReportsView, SettingsView
- **iPad Views**: iPadCoachingLogView (split-view optimized)
- **Detail Views**: EntryDetailView, NoteDetailView, EmployeeProfileView
- **Input Views**: AddEntryView, AddEmployeeView, AddNoteView, AddTemplateView
- **Utility Views**: PINEntryView, PINSetupView, FilterView, AboutView, TemplatesView

### Utilities
- `ExportManager`: Handles CSV and PDF export generation
- `NotificationManager`: Manages local push notifications
- `ShareSheet`: UIKit wrapper for sharing functionality

### State Management
- `AppState`: Global app state (PIN, locks, tabs, notifications)
- Environment objects for shared state
- SwiftData for persistent storage

## Project Structure

```
CoachingLog/
├── CoachingLogApp.swift          # App entry point
├── ContentView.swift             # Adaptive main view (iPhone/iPad)
├── AppState.swift                # Global state management
├── Theme.swift                   # Theme colors and styles
├── Models/
│   ├── Employee.swift
│   ├── CoachingEntry.swift
│   ├── PersonalNote.swift
│   ├── Goal.swift
│   ├── EntryTemplate.swift
│   └── Reminder.swift
├── Views/
│   ├── CoachingLogView.swift
│   ├── iPadCoachingLogView.swift  # iPad-optimized split view
│   ├── NotesView.swift
│   ├── ReportsView.swift
│   ├── SettingsView.swift
│   ├── EntryDetailView.swift
│   ├── NoteDetailView.swift
│   ├── EmployeeProfileView.swift
│   ├── AddEntryView.swift
│   ├── AddEmployeeView.swift
│   ├── AddNoteView.swift
│   ├── AddTemplateView.swift
│   ├── TemplatesView.swift
│   ├── PINEntryView.swift
│   ├── PINSetupView.swift
│   ├── FilterView.swift
│   └── AboutView.swift
└── Utilities/
    ├── ExportManager.swift         # CSV/PDF export
    ├── NotificationManager.swift   # Push notifications
    └── ShareSheet.swift            # Share functionality
```

## Getting Started

1. Open the project in Xcode 15 or later
2. Select your target device (iPhone or iPad)
3. Build and run the project
4. **Grant notification permissions** when prompted (optional but recommended)
5. Start adding employees and creating coaching entries!

## Key Features Walkthrough

### Creating Your First Entry
1. Tap the "+" button in the Coaching Log tab
2. Optionally select a template for quick setup
3. Fill in the entry details
4. Add photos, tags, and set follow-up reminders
5. Save and receive automatic notifications

### Using Templates
1. Go to Settings → Manage Templates
2. Create templates for common scenarios
3. When creating a new entry, tap "Use Template"
4. Your content and category are pre-filled

### Bulk Operations
1. In Coaching Log, tap the menu → "Select Multiple"
2. Select entries you want to delete
3. Tap the trash icon
4. Confirm deletion

### Exporting Data
1. Navigate to the Reports tab
2. Select your desired time range
3. Tap the export button
4. Choose CSV or PDF format
5. Share via email, Files, or other apps

### iPad Features
- Split-view automatically activates on iPad
- Browse entries in the sidebar
- View details in the main panel
- Drag to resize panels
- Full keyboard support

## Future Enhancements

- [ ] Custom entry categories
- [ ] Dark/Light theme toggle
- [ ] iCloud sync (optional)
- [ ] Widgets for quick access
- [ ] Siri Shortcuts integration
- [ ] Apple Watch companion app
- [ ] Advanced filtering options
- [ ] Batch import from CSV
- [ ] Customizable PDF report templates
- [ ] Goal progress tracking charts

## Version History

### **1.0.0** - Initial Release
- ✅ Core coaching log functionality
- ✅ Employee management with profiles
- ✅ Reports and analytics with charts
- ✅ Personal notes
- ✅ PIN security
- ✅ **Entry templates system**
- ✅ **Bulk operations (select & delete)**
- ✅ **CSV and PDF export**
- ✅ **Local push notifications**
- ✅ **iPad split-view optimization**
- ✅ Offline-first architecture
- ✅ Photo attachments
- ✅ Follow-up reminders
- ✅ Birthday and anniversary tracking

