//
//  AboutView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // App Icon
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "list.clipboard")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Coaching Log")
                                .font(AppTheme.interFont(size: 28, weight: .bold))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Text("Version 1.0.0")
                                .font(AppTheme.interFont(size: 14))
                                .foregroundStyle(AppTheme.textMuted)
                        }
                        .padding(.top, 40)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About")
                                .font(AppTheme.interFont(size: 20, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            Text("Coaching Log is a comprehensive employee management and coaching application designed for managers and team leaders. Track employee performance, manage goals, schedule follow-ups, and maintain detailed records of all interactions.")
                                .font(AppTheme.interFont(size: 15))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Features")
                                .font(AppTheme.interFont(size: 20, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            
                            FeatureRow(
                                icon: "doc.text.fill",
                                title: "Detailed Entries",
                                description: "Create comprehensive coaching entries with photos and tags"
                            )
                            
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Employee Profiles",
                                description: "Manage employee information, goals, and important dates"
                            )
                            
                            FeatureRow(
                                icon: "chart.bar.fill",
                                title: "Reports & Analytics",
                                description: "Visualize trends and track team performance"
                            )
                            
                            FeatureRow(
                                icon: "bell.fill",
                                title: "Reminders",
                                description: "Never miss a follow-up, birthday, or anniversary"
                            )
                            
                            FeatureRow(
                                icon: "lock.fill",
                                title: "Secure & Private",
                                description: "All data stored locally with optional PIN protection"
                            )
                        }
                        .padding()
                        .background(AppTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Credits
                        VStack(spacing: 8) {
                            Text("Made with ❤️ for iOS and iPadOS")
                                .font(AppTheme.interFont(size: 14))
                                .foregroundStyle(AppTheme.textMuted)
                            
                            Text("© 2026 Coaching Log")
                                .font(AppTheme.interFont(size: 12))
                                .foregroundStyle(AppTheme.textMuted)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.accentPurple)
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.accentPurple)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(description)
                    .font(AppTheme.interFont(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
}

#Preview {
    AboutView()
}
