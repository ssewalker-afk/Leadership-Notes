//
//  SettingsView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("followUpReminderDays") private var followUpReminderDays = 1
    @AppStorage("birthdayReminderDays") private var birthdayReminderDays = 7
    @AppStorage("anniversaryReminderDays") private var anniversaryReminderDays = 7
    
    @State private var showingPINSetup = false
    @State private var showingPINRemoval = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                List {
                    // Security Section
                    Section {
                        Toggle(isOn: Binding(
                            get: { appState.hasSetPIN },
                            set: { enabled in
                                if enabled {
                                    showingPINSetup = true
                                } else {
                                    showingPINRemoval = true
                                }
                            }
                        )) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(AppTheme.accentPurple)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PIN Protection")
                                        .font(AppTheme.interFont(size: 16, weight: .medium))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    
                                    Text("Require PIN to open app")
                                        .font(AppTheme.interFont(size: 13))
                                        .foregroundStyle(AppTheme.textMuted)
                                }
                            }
                        }
                        .tint(AppTheme.accentPurple)
                        
                        if appState.hasSetPIN {
                            Button {
                                showingPINSetup = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "key.fill")
                                        .foregroundStyle(AppTheme.accentCyan)
                                        .frame(width: 24)
                                    
                                    Text("Change PIN")
                                        .font(AppTheme.interFont(size: 16, weight: .medium))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundStyle(AppTheme.textMuted)
                                }
                            }
                        }
                    } header: {
                        Text("Security")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    // Notifications Section
                    Section {
                        Toggle(isOn: $notificationsEnabled) {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(AppTheme.accentPink)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notifications")
                                        .font(AppTheme.interFont(size: 16, weight: .medium))
                                        .foregroundStyle(AppTheme.textPrimary)
                                    
                                    Text("Enable in-app notifications")
                                        .font(AppTheme.interFont(size: 13))
                                        .foregroundStyle(AppTheme.textMuted)
                                }
                            }
                        }
                        .tint(AppTheme.accentPurple)
                        
                        if notificationsEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundStyle(AppTheme.accentCyan)
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Follow-up Reminders")
                                            .font(AppTheme.interFont(size: 16, weight: .medium))
                                            .foregroundStyle(AppTheme.textPrimary)
                                        
                                        Stepper("\(followUpReminderDays) day\(followUpReminderDays == 1 ? "" : "s") before", value: $followUpReminderDays, in: 0...30)
                                            .font(AppTheme.interFont(size: 13))
                                            .foregroundStyle(AppTheme.textMuted)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    Image(systemName: "gift.fill")
                                        .foregroundStyle(Color(hex: "10B981"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Birthday Reminders")
                                            .font(AppTheme.interFont(size: 16, weight: .medium))
                                            .foregroundStyle(AppTheme.textPrimary)
                                        
                                        Stepper("\(birthdayReminderDays) day\(birthdayReminderDays == 1 ? "" : "s") before", value: $birthdayReminderDays, in: 0...30)
                                            .font(AppTheme.interFont(size: 13))
                                            .foregroundStyle(AppTheme.textMuted)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(Color(hex: "F59E0B"))
                                        .frame(width: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Anniversary Reminders")
                                            .font(AppTheme.interFont(size: 16, weight: .medium))
                                            .foregroundStyle(AppTheme.textPrimary)
                                        
                                        Stepper("\(anniversaryReminderDays) day\(anniversaryReminderDays == 1 ? "" : "s") before", value: $anniversaryReminderDays, in: 0...30)
                                            .font(AppTheme.interFont(size: 13))
                                            .foregroundStyle(AppTheme.textMuted)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Notifications")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    // Data Management Section
                    Section {
                        NavigationLink(destination: TemplatesView()) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundStyle(AppTheme.accentCyan)
                                    .frame(width: 24)
                                
                                Text("Manage Templates")
                                    .font(AppTheme.interFont(size: 16, weight: .medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                        }
                    } header: {
                        Text("Data Management")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                    
                    // About Section
                    Section {
                        Button {
                            showingAbout = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(AppTheme.accentPurple)
                                    .frame(width: 24)
                                
                                Text("About")
                                    .font(AppTheme.interFont(size: 16, weight: .medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppTheme.textMuted)
                            }
                        }
                    } header: {
                        Text("App Information")
                            .font(AppTheme.interFont(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                    .listRowBackground(AppTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPINSetup) {
                PINSetupView()
            }
            .alert("Remove PIN", isPresented: $showingPINRemoval) {
                Button("Cancel", role: .cancel) {}
                Button("Remove", role: .destructive) {
                    appState.removePIN()
                }
            } message: {
                Text("Are you sure you want to remove PIN protection?")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
