//
//  ContentView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            if appState.isLocked {
                PINEntryView()
            } else {
                mainContent
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var mainContent: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad layout
                iPadMainView()
            } else {
                // iPhone layout
                iPhoneMainView()
            }
        }
    }
    
    private func iPhoneMainView() -> some View {
        TabView(selection: $appState.currentTab) {
            CoachingLogView()
                .tabItem {
                    Label("Coaching Log", systemImage: "list.clipboard")
                }
                .tag(AppState.Tab.coachingLog)
            
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "chart.bar")
                }
                .tag(AppState.Tab.reports)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppState.Tab.settings)
        }
        .tint(AppTheme.accentPurple)
    }
    
    private func iPadMainView() -> some View {
        NavigationSplitView {
            // Sidebar
            List(AppState.Tab.allCases, id: \.self, selection: $appState.currentTab) { tab in
                Label(tab.rawValue, systemImage: tab.icon)
                    .font(AppTheme.interFont(size: 16, weight: .medium))
                    .foregroundStyle(appState.currentTab == tab ? AppTheme.accentPurple : AppTheme.textPrimary)
            }
            .listStyle(.sidebar)
            .navigationTitle("Coaching Log")
        } detail: {
            // Detail content based on selected tab
            switch appState.currentTab {
            case .coachingLog:
                iPadCoachingLogView()
            case .reports:
                ReportsView()
            case .settings:
                SettingsView()
            }
        }
        .tint(AppTheme.accentPurple)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .modelContainer(for: [
            Employee.self,
            CoachingEntry.self,
            PersonalNote.self,
            Goal.self,
            EntryTemplate.self,
            Reminder.self
        ])
}
