//
//  CoachingLogView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData

struct CoachingLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoachingEntry.date, order: .reverse) private var entries: [CoachingEntry]
    @Query(sort: \Employee.lastName) private var employees: [Employee]
    
    @State private var showingAddEntry = false
    @State private var showingAddEmployee = false
    @State private var searchText = ""
    @State private var selectedCategory: EntryCategory?
    @State private var selectedEmployee: Employee?
    @State private var showingFilters = false
    @State private var isSelectionMode = false
    @State private var selectedEntries: Set<CoachingEntry.ID> = []
    @State private var showingBulkDeleteConfirmation = false
    
    var filteredEntries: [CoachingEntry] {
        var result = entries
        
        if !searchText.isEmpty {
            result = result.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.employee?.fullName.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category.rawValue }
        }
        
        if let employee = selectedEmployee {
            result = result.filter { $0.employee?.id == employee.id }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Stats
                    statsHeader
                    
                    // Main Content
                    if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        entriesList
                    }
                }
            }
            .navigationTitle(isSelectionMode ? "\(selectedEntries.count) Selected" : "Coaching Log")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isSelectionMode {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedEntries.removeAll()
                        }
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelectionMode {
                        HStack(spacing: 16) {
                            Button {
                                if selectedEntries.count == filteredEntries.count {
                                    selectedEntries.removeAll()
                                } else {
                                    selectedEntries = Set(filteredEntries.map { $0.id })
                                }
                            } label: {
                                Text(selectedEntries.count == filteredEntries.count ? "Deselect All" : "Select All")
                                    .foregroundStyle(AppTheme.accentCyan)
                            }
                            
                            Button {
                                showingBulkDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                            .disabled(selectedEntries.isEmpty)
                        }
                    } else {
                        Menu {
                            Button {
                                showingAddEntry = true
                            } label: {
                                Label("New Entry", systemImage: "doc.badge.plus")
                            }
                            
                            Button {
                                showingAddEmployee = true
                            } label: {
                                Label("New Employee", systemImage: "person.badge.plus")
                            }
                            
                            Divider()
                            
                            Button {
                                showingFilters = true
                            } label: {
                                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                            }
                            
                            if !filteredEntries.isEmpty {
                                Divider()
                                
                                Button {
                                    isSelectionMode = true
                                } label: {
                                    Label("Select Multiple", systemImage: "checkmark.circle")
                                }
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(AppTheme.accentPurple)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search entries...")
            .sheet(isPresented: $showingAddEntry) {
                AddEntryView()
            }
            .sheet(isPresented: $showingAddEmployee) {
                AddEmployeeView()
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedCategory: $selectedCategory,
                    selectedEmployee: $selectedEmployee,
                    employees: employees
                )
            }
            .confirmationDialog("Delete \(selectedEntries.count) Entries", isPresented: $showingBulkDeleteConfirmation) {
                Button("Delete \(selectedEntries.count) Entries", role: .destructive) {
                    bulkDeleteEntries()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \(selectedEntries.count) entries? This action cannot be undone.")
            }
        }
    }
    
    private var statsHeader: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Entries",
                value: "\(entries.count)",
                icon: "doc.text.fill",
                color: AppTheme.accentPurple
            )
            
            StatCard(
                title: "Employees",
                value: "\(employees.count)",
                icon: "person.2.fill",
                color: AppTheme.accentCyan
            )
            
            StatCard(
                title: "This Month",
                value: "\(entriesThisMonth)",
                icon: "calendar",
                color: AppTheme.accentPink
            )
        }
        .padding()
    }
    
    private var entriesThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return entries.filter { entry in
            calendar.isDate(entry.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredEntries) { entry in
                    if isSelectionMode {
                        Button {
                            if selectedEntries.contains(entry.id) {
                                selectedEntries.remove(entry.id)
                            } else {
                                selectedEntries.insert(entry.id)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selectedEntries.contains(entry.id) ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedEntries.contains(entry.id) ? AppTheme.accentPurple : AppTheme.textMuted)
                                
                                EntryCard(entry: entry)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        NavigationLink(destination: EntryDetailView(entry: entry)) {
                            EntryCard(entry: entry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
    }
    
    private func bulkDeleteEntries() {
        let entriesToDelete = entries.filter { selectedEntries.contains($0.id) }
        for entry in entriesToDelete {
            modelContext.delete(entry)
        }
        selectedEntries.removeAll()
        isSelectionMode = false
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 80))
                .foregroundStyle(AppTheme.textMuted)
            
            Text("No Entries Yet")
                .font(AppTheme.interFont(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text("Start by creating your first coaching entry or adding an employee.")
                .font(AppTheme.interFont(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddEntry = true
            } label: {
                Label("Create Entry", systemImage: "plus")
                    .font(AppTheme.interFont(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(AppTheme.interFont(size: 24, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(title)
                .font(AppTheme.interFont(size: 12))
                .foregroundStyle(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EntryCard: View {
    let entry: CoachingEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let employee = entry.employee {
                    Text(employee.fullName)
                        .font(AppTheme.interFont(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.accentPurple)
                }
                
                Spacer()
                
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(AppTheme.interFont(size: 12))
                    .foregroundStyle(AppTheme.textMuted)
            }
            
            Text(entry.title)
                .font(AppTheme.interFont(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)
            
            Text(entry.content)
                .font(AppTheme.interFont(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(3)
            
            HStack {
                CategoryBadge(category: entry.category)
                
                Spacer()
                
                if entry.followUpDate != nil && !entry.isFollowUpComplete {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 10))
                        Text("Follow-up")
                            .font(AppTheme.interFont(size: 11, weight: .medium))
                    }
                    .foregroundStyle(AppTheme.accentCyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.accentCyan.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryBadge: View {
    let category: String
    
    var categoryEnum: EntryCategory? {
        EntryCategory.allCases.first { $0.rawValue == category }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let cat = categoryEnum {
                Image(systemName: cat.icon)
                    .font(.system(size: 10))
                Text(category)
                    .font(AppTheme.interFont(size: 11, weight: .medium))
            } else {
                Text(category)
                    .font(AppTheme.interFont(size: 11, weight: .medium))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(hex: categoryEnum?.color ?? "6B7280"))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    CoachingLogView()
        .environmentObject(AppState())
        .modelContainer(for: [
            Employee.self,
            CoachingEntry.self
        ])
}
