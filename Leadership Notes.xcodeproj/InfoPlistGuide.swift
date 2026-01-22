//
//  Info.plist Configuration Guide
//  CoachingLog
//
//  Add these entries to your Info.plist file
//

/*
 
 REQUIRED: Notification Permission Description
 
 Add this key-value pair to Info.plist:
 
 Key: NSUserNotificationsUsageDescription
 Value: "Coaching Log sends you reminders for follow-ups, employee birthdays, and work anniversaries to help you stay organized and maintain strong team relationships."
 
 
 XML Format (for direct plist editing):
 
 <key>NSUserNotificationsUsageDescription</key>
 <string>Coaching Log sends you reminders for follow-ups, employee birthdays, and work anniversaries to help you stay organized and maintain strong team relationships.</string>
 
 
 OPTIONAL: Privacy - Camera Usage Description (if using camera for photos)
 
 Key: NSCameraUsageDescription
 Value: "Coaching Log needs access to your camera to capture photos for employee profiles and coaching entries."
 
 <key>NSCameraUsageDescription</key>
 <string>Coaching Log needs access to your camera to capture photos for employee profiles and coaching entries.</string>
 
 
 OPTIONAL: Privacy - Photo Library Usage Description
 
 Key: NSPhotoLibraryUsageDescription  
 Value: "Coaching Log needs access to your photo library to attach photos to coaching entries and employee profiles."
 
 <key>NSPhotoLibraryUsageDescription</key>
 <string>Coaching Log needs access to your photo library to attach photos to coaching entries and employee profiles.</string>
 
 
 RECOMMENDED: App Display Name
 
 Key: CFBundleDisplayName
 Value: Coaching Log
 
 <key>CFBundleDisplayName</key>
 <string>Coaching Log</string>
 
 
 RECOMMENDED: Supported Interfaces
 
 Ensure your app supports both iPhone and iPad:
 
 Key: UIDeviceFamily
 Value: Array with items 1 (iPhone) and 2 (iPad)
 
 <key>UIDeviceFamily</key>
 <array>
     <integer>1</integer>
     <integer>2</integer>
 </array>
 
 
 RECOMMENDED: Supported Orientations (iPad)
 
 Key: UISupportedInterfaceOrientations~ipad
 Value: Array with all orientations for best iPad experience
 
 <key>UISupportedInterfaceOrientations~ipad</key>
 <array>
     <string>UIInterfaceOrientationPortrait</string>
     <string>UIInterfaceOrientationPortraitUpsideDown</string>
     <string>UIInterfaceOrientationLandscapeLeft</string>
     <string>UIInterfaceOrientationLandscapeRight</string>
 </array>
 
 
 STEPS TO ADD TO YOUR PROJECT:
 
 1. In Xcode, select your project in the navigator
 2. Select your target
 3. Go to the "Info" tab
 4. Click the "+" button to add a new key
 5. Start typing the key name (e.g., "NSUserNotificationsUsageDescription")
 6. Xcode will auto-complete - select the correct one
 7. Enter the value in the text field
 8. Repeat for all required and optional keys
 
 OR
 
 1. Right-click Info.plist in the project navigator
 2. Select "Open As" → "Source Code"
 3. Copy and paste the XML entries between the <dict> tags
 4. Save the file
 
 */
