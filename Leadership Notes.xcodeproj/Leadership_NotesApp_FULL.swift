//
//  Leadership_NotesApp_FULL.swift
//  Leadership Notes
//
//  USE THIS VERSION after adding all files to the Leadership Notes target
//  Copy the contents below and replace Leadership_NotesApp.swift
//

import SwiftUI
import SwiftData

@main
struct Leadership_NotesApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var storeManager = StoreManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if storeManager.isPremium {
                    ContentView()
                        .environmentObject(appState)
                } else {
                    PaywallView(storeManager: storeManager)
                }
            }
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
