//
//  ReportsView.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI
import SwiftData
import Charts

struct ReportsView: View {
    @Query private var entries: [CoachingEntry]
    @Query private var employees: [Employee]
    
    @State private var selectedTimeRange: TimeRange = .month
    @State private var showingExportOptions = false
    @State private var exportFileURL: URL?
    @State private var showingShareSheet = false
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        case all = "All Time"
    }
    
    var filteredEntries: [CoachingEntry] {
        let now = Date()
        let calendar = Calendar.current
        
        switch selectedTimeRange {
        case .week:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return entries.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return entries.filter { $0.date >= monthAgo }
        case .quarter:
            let quarterAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return entries.filter { $0.date >= quarterAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return entries.filter { $0.date >= yearAgo }
        case .all:
            return entries
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundPrimary.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Time Range Picker
                        timeRangePicker
                        
                        // Summary Stats
                        summaryStats
                        
                        // Entries Over Time Chart
                        entriesOverTimeChart
                        
                        // Category Distribution Chart
                        categoryDistributionChart
                        
                        // Top Employees Chart
                        topEmployeesChart
                    }
                    .padding()
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingExportOptions = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(AppTheme.accentPurple)
                    }
                }
            }
            .confirmationDialog("Export Data", isPresented: $showingExportOptions) {
                Button("Export as CSV") {
                    exportAsCSV()
                }
                Button("Export as PDF") {
                    exportAsPDF()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var summaryStats: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ReportStatCard(
                    title: "Total Entries",
                    value: "\(filteredEntries.count)",
                    icon: "doc.text.fill",
                    color: AppTheme.accentPurple
                )
                
                ReportStatCard(
                    title: "Active Employees",
                    value: "\(activeEmployeesCount)",
                    icon: "person.2.fill",
                    color: AppTheme.accentCyan
                )
            }
            
            HStack(spacing: 12) {
                ReportStatCard(
                    title: "Avg per Week",
                    value: String(format: "%.1f", averagePerWeek),
                    icon: "chart.line.uptrend.xyaxis",
                    color: AppTheme.accentPink
                )
                
                ReportStatCard(
                    title: "Most Common",
                    value: mostCommonCategory,
                    icon: "tag.fill",
                    color: Color(hex: "10B981")
                )
            }
        }
    }
    
    private var entriesOverTimeChart: some View {
        ChartCard(title: "Entries Over Time") {
            Chart(entriesByWeek, id: \.week) { item in
                BarMark(
                    x: .value("Week", item.week, unit: .weekOfYear),
                    y: .value("Count", item.count)
                )
                .foregroundStyle(AppTheme.accentPurple)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textMuted.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.textMuted)
                        .font(AppTheme.interFont(size: 10))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textMuted.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.textMuted)
                        .font(AppTheme.interFont(size: 10))
                }
            }
            .frame(height: 200)
        }
    }
    
    private var categoryDistributionChart: some View {
        ChartCard(title: "Category Distribution") {
            Chart(categoryData, id: \.category) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(Color(hex: item.color))
                .annotation(position: .overlay) {
                    if item.count > 0 {
                        Text("\(item.count)")
                            .font(AppTheme.interFont(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 250)
            
            // Legend
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(categoryData, id: \.category) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: item.color))
                            .frame(width: 8, height: 8)
                        Text(item.category)
                            .font(AppTheme.interFont(size: 11))
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text("\(item.count)")
                            .font(AppTheme.interFont(size: 11, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var topEmployeesChart: some View {
        ChartCard(title: "Most Active Employees") {
            Chart(topEmployees, id: \.name) { item in
                BarMark(
                    x: .value("Count", item.count),
                    y: .value("Employee", item.name)
                )
                .foregroundStyle(AppTheme.accentCyan)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppTheme.textMuted.opacity(0.3))
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.textMuted)
                        .font(AppTheme.interFont(size: 10))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(AppTheme.textSecondary)
                        .font(AppTheme.interFont(size: 12))
                }
            }
            .frame(height: 200)
        }
    }
    
    // MARK: - Computed Properties
    
    private var activeEmployeesCount: Int {
        let employeeIDs = Set(filteredEntries.compactMap { $0.employee?.id })
        return employeeIDs.count
    }
    
    private var averagePerWeek: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldestDate = filteredEntries.map { $0.date }.min() ?? Date()
        let weeks = max(1, calendar.dateComponents([.weekOfYear], from: oldestDate, to: Date()).weekOfYear ?? 1)
        return Double(filteredEntries.count) / Double(weeks)
    }
    
    private var mostCommonCategory: String {
        let categories = filteredEntries.map { $0.category }
        let counts = categories.reduce(into: [:]) { counts, category in
            counts[category, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "N/A"
    }
    
    private var entriesByWeek: [(week: Date, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
        }
        return grouped.map { (week: $0.key, count: $0.value.count) }
            .sorted { $0.week < $1.week }
    }
    
    private var categoryData: [(category: String, count: Int, color: String)] {
        let grouped = Dictionary(grouping: filteredEntries) { $0.category }
        return grouped.map { category, entries in
            let color = EntryCategory.allCases.first { $0.rawValue == category }?.color ?? "6B7280"
            return (category: category, count: entries.count, color: color)
        }.sorted { $0.count > $1.count }
    }
    
    private var topEmployees: [(name: String, count: Int)] {
        let grouped = Dictionary(grouping: filteredEntries.compactMap { $0.employee }) { $0.id }
        return grouped.compactMap { _, employees in
            guard let employee = employees.first else { return nil }
            let count = filteredEntries.filter { $0.employee?.id == employee.id }.count
            return (name: employee.fullName, count: count)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }
    
    // MARK: - Export Functions
    
    private func exportAsCSV() {
        if let url = ExportManager.exportToCSV(entries: filteredEntries) {
            exportFileURL = url
            showingShareSheet = true
        }
    }
    
    private func exportAsPDF() {
        if let url = ExportManager.exportToPDF(entries: filteredEntries, employees: employees) {
            exportFileURL = url
            showingShareSheet = true
        }
    }
}

struct ReportStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
            
            Text(value)
                .font(AppTheme.interFont(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
            
            Text(title)
                .font(AppTheme.interFont(size: 11))
                .foregroundStyle(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTheme.interFont(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
            
            content
        }
        .padding()
        .background(AppTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ReportsView()
        .environmentObject(AppState())
        .modelContainer(for: [CoachingEntry.self, Employee.self])
}
