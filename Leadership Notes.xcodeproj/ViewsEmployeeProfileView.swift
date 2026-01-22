//
//  EmployeeProfileView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct EmployeeProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var employee: Employee
    @Query private var allEntries: [CoachingEntry]
    
    @State private var showingDeleteConfirmation = false
    @State private var isEditingNotes = false
    
    var employeeEntries: [CoachingEntry] {
        allEntries.filter { $0.employee?.id == employee.id }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader
                
                // Quick Stats
                quickStats
                
                // Important Dates
                if employee.birthday != nil || employee.hireDate != nil {
                    importantDates
                }
                
                // Employee Notes
                employeeNotes
                
                // Goals
                goalsSection
                
                // Recent Entries
                recentEntriesSection
            }
            .padding()
        }
        .background(AppTheme.backgroundPrimary)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Employee", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .confirmationDialog("Delete Employee", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteEmployee()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure? This will also delete all entries for this employee.")
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Photo
            if let imageData = employee.profileImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 120, height: 120)
                    
                    Text(employee.initials)
                        .font(AppTheme.interFont(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(spacing: 8) {
                Text(employee.fullName)
                    .font(AppTheme.interFont(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                if let jobTitle = employee.jobTitle {
                    Text(jobTitle)
                        .font(AppTheme.interFont(size: 16))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                if let department = employee.department {
                    Text(department)
                        .font(AppTheme.interFont(size: 14))
                        .foregroundStyle(AppTheme.textMuted)
                }
            }
            
            // Contact Info
            if employee.email != nil || employee.phoneNumber != nil {
                HStack(spacing: 20) {
                    if let email = employee.email, !email.isEmpty {
                        Button {
                            if let url = URL(string: "mailto:\(email)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "envelope.fill")
                                Text("Email")
                            }
                            .font(AppTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.accentPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    if let phone = employee.phoneNumber, !phone.isEmpty {
                        Button {
                            if let url = URL(string: "tel:\(phone)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "phone.fill")
                                Text("Call")
                            }
                            .font(AppTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.accentCyan)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var quickStats: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Total Entries",
                value: "\(employeeEntries.count)",
                icon: "doc.text.fill",
                color: AppTheme.accentPurple
            )
            
            StatCard(
                title: "This Month",
                value: "\(entriesThisMonth)",
                icon: "calendar",
                color: AppTheme.accentCyan
            )
            
            if let years = employee.yearsEmployed {
                StatCard(
                    title: "Years",
                    value: "\(years)",
                    icon: "star.fill",
                    color: AppTheme.accentPink
                )
            }
        }
    }
    
    private var entriesThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return employeeEntries.filter { entry in
            calendar.isDate(entry.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var importantDates: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Important Dates")
                .font(AppTheme.interFont(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            if let birthday = employee.birthday {
                HStack(spacing: 12) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(AppTheme.accentPink)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Birthday")
                            .font(AppTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text(birthday.formatted(date: .abbreviated, time: .omitted))
                            .font(AppTheme.interFont(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    if let upcoming = employee.upcomingBirthday {
                        Text(daysUntil(upcoming))
                            .font(AppTheme.interFont(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.accentPink)
                    }
                }
            }
            
            if let hireDate = employee.hireDate {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color(hex: "F59E0B"))
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Work Anniversary")
                            .font(AppTheme.interFont(size: 14, weight: .medium))
                            .foregroundStyle(AppTheme.textPrimary)
                        
                        Text(hireDate.formatted(date: .abbreviated, time: .omitted))
                            .font(AppTheme.interFont(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    if let upcoming = employee.upcomingAnniversary {
                        Text(daysUntil(upcoming))
                            .font(AppTheme.interFont(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: "F59E0B"))
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var employeeNotes: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notes")
                    .font(AppTheme.interFont(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
                Button {
                    isEditingNotes.toggle()
                    if !isEditingNotes {
                        employee.modifiedDate = Date()
                    }
                } label: {
                    Text(isEditingNotes ? "Done" : "Edit")
                        .font(AppTheme.interFont(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.accentPurple)
                }
            }
            
            if isEditingNotes {
                TextEditor(text: Binding(
                    get: { employee.notes ?? "" },
                    set: { employee.notes = $0.isEmpty ? nil : $0 }
                ))
                .font(AppTheme.interFont(size: 15))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(AppTheme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Text(employee.notes ?? "No notes")
                    .font(AppTheme.interFont(size: 15))
                    .foregroundStyle(employee.notes == nil ? AppTheme.textMuted : AppTheme.textSecondary)
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goals")
                .font(AppTheme.interFont(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            if let goals = employee.goals, !goals.isEmpty {
                ForEach(goals) { goal in
                    GoalRow(goal: goal)
                }
            } else {
                Text("No goals set")
                    .font(AppTheme.interFont(size: 15))
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Entries")
                .font(AppTheme.interFont(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            if employeeEntries.isEmpty {
                Text("No entries yet")
                    .font(AppTheme.interFont(size: 15))
                    .foregroundStyle(AppTheme.textMuted)
            } else {
                ForEach(employeeEntries.prefix(5)) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry)) {
                        CompactEntryCard(entry: entry)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func daysUntil(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "in \(days) days"
        }
    }
    
    private func deleteEmployee() {
        modelContext.delete(employee)
        dismiss()
    }
}

struct GoalRow: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(AppTheme.interFont(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            if let targetDate = goal.targetDate {
                Text("Target: \(targetDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(AppTheme.interFont(size: 12))
                    .foregroundStyle(goal.isOverdue ? .red : AppTheme.textMuted)
            }
            
            ProgressView(value: Double(goal.progress), total: 100)
                .tint(goal.isCompleted ? .green : AppTheme.accentPurple)
        }
        .padding()
        .background(AppTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CompactEntryCard: View {
    let entry: CoachingEntry
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(AppTheme.interFont(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
                
                Text(entry.content)
                    .font(AppTheme.interFont(size: 13))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                CategoryBadge(category: entry.category)
                
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.interFont(size: 11))
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
        .padding()
        .background(AppTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        EmployeeProfileView(employee: Employee(firstName: "John", lastName: "Doe", jobTitle: "Software Engineer"))
    }
    .modelContainer(for: [Employee.self, CoachingEntry.self])
}
