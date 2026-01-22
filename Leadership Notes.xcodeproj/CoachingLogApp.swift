//
//  CoachingLogApp.swift
//  CoachingLog
//
//  Created on 1/20/26.
//
//  NOTE: This file is NOT used in the Leadership Notes target.
//  The active app entry point is Leadership_NotesApp.swift
//

import SwiftUI
import SwiftData

// DISABLED: Not using this file - using Leadership_NotesApp instead
// @main
struct CoachingLogApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(for: [
                    Employee.self,
                    CoachingEntry.self,
                    PersonalNote.self,
                    Goal.self,
                    EntryTemplate.self,
                    Reminder.self
                ])
        }
    }
}
