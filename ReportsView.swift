import SwiftUI

struct ReportsView: View {
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var filterPerson = "all"
    @State private var filterTeam = "all"
    @State private var showPreview = false
    
    private var activeTeams: [Team] {
        store.teams.filter { $0.active }
    }
    
    private var filteredEntries: [Entry] {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        
        return store.entries.filter { entry in
            guard entry.timestamp >= startDate && entry.timestamp <= endOfDay else {
                return false
            }
            
            if filterPerson != "all" && entry.personId != filterPerson {
                return false
            }
            
            if filterTeam != "all" {
                guard let person = store.people.first(where: { $0.id == entry.personId }),
                      person.teamId == filterTeam else {
                    return false
                }
            }
            
            return true
        }
    }
    
    private var uniquePeopleCount: Int {
        Set(filteredEntries.map { $0.personId }).count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📊 Reports")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(theme.accent)
            
            // Filters
            CardView(theme: theme) {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        VStack(alignment: .leading) {
                            SectionLabel(text: "START", theme: theme)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(8)
                                .background(theme.bgInput)
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading) {
                            SectionLabel(text: "END", theme: theme)
                            DatePicker("", selection: $endDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(8)
                                .background(theme.bgInput)
                                .cornerRadius(10)
                        }
                    }
                    
                    Picker("Person", selection: $filterPerson) {
                        Text("All People").tag("all")
                        ForEach(store.people) { person in
                            Text(person.name).tag(person.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(11)
                    .background(theme.bgInput)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.border, lineWidth: 1.5)
                    )
                    
                    if activeTeams.count > 1 {
                        Picker("Team", selection: $filterTeam) {
                            Text("All Teams").tag("all")
                            ForEach(activeTeams) { team in
                                Text(team.name).tag(team.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(11)
                        .background(theme.bgInput)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(theme.border, lineWidth: 1.5)
                        )
                    }
                }
                .padding(16)
            }
            
            // Stats
            HStack(spacing: 10) {
                StatCard(value: "\(filteredEntries.count)", label: "ENTRIES", theme: theme)
                StatCard(value: "\(uniquePeopleCount)", label: "PEOPLE", theme: theme, accentColor: theme.warn)
            }
            
            // Heat map
            heatMap
            
            // Actions
            Button(action: emailReport) {
                Text("📧 Email Report")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.gradient)
                    .cornerRadius(12)
            }
            
            Button(action: { showPreview.toggle() }) {
                Text(showPreview ? "Hide" : "👁️ Preview")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.accentGlow)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.borderAccent, lineWidth: 1)
                    )
            }
            
            if showPreview {
                CardView(theme: theme) {
                    ScrollView {
                        Text(generateReportText())
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(theme.textSoft)
                            .padding(16)
                    }
                    .frame(maxHeight: 300)
                }
            }
        }
    }
    
    // MARK: - Heat Map
    private var heatMap: some View {
        CardView(theme: theme) {
            VStack(alignment: .leading, spacing: 10) {
                Text("🔥 HEAT MAP")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(theme.accent)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
                    ForEach(store.categories) { category in
                        HeatMapCell(
                            category: category,
                            count: filteredEntries.filter { $0.category == category.id }.count,
                            maxCount: maxCategoryCount,
                            theme: theme
                        )
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var maxCategoryCount: Int {
        store.categories.map { category in
            filteredEntries.filter { $0.category == category.id }.count
        }.max() ?? 1
    }
    
    // MARK: - Report Generation
    private func generateReportText() -> String {
        var lines: [String] = []
        
        lines.append("LEADERSHIP NOTES REPORT")
        lines.append("\(startDate.shortDate()) — \(endDate.shortDate())")
        lines.append("Total: \(filteredEntries.count) entries")
        lines.append("")
        
        let groupedByPerson = Dictionary(grouping: filteredEntries) { $0.personId }
        
        for (personId, entries) in groupedByPerson.sorted(by: { $0.value.count > $1.value.count }) {
            let person = store.people.first { $0.id == personId }
            let personName = person?.name ?? entries.first?.personName ?? "?"
            
            lines.append("=== \(personName) (\(entries.count)) ===")
            
            for entry in entries.sorted(by: { $0.timestamp < $1.timestamp }) {
                let category = store.categories.first { $0.id == entry.category }
                var line = "  \(entry.timestamp.shortDate()) | \(category?.icon ?? "") \(category?.label ?? entry.category)"
                
                if let subType = entry.subType {
                    line += " - \(subType)"
                }
                
                if let duration = entry.duration {
                    line += " - \(duration) min"
                }
                
                if entry.notice == true {
                    line += " (Notice)"
                } else if entry.notice == false && category?.hasNotice == true {
                    line += " (No notice)"
                }
                
                lines.append(line)
                
                if !entry.notes.isEmpty {
                    lines.append("    \(entry.notes)")
                }
            }
            
            lines.append("")
        }
        
        return lines.joined(separator: "\n")
    }
    
    private func emailReport() {
        let body = generateReportText()
        let personName = filterPerson != "all" ? (store.people.first { $0.id == filterPerson }?.name ?? "All") : "All"
        let subject = "Leadership Notes - \(personName) - \(startDate.shortDate()) to \(endDate.shortDate())"
        
        if let encoded = "mailto:?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            #if os(iOS)
            UIApplication.shared.open(url)
            #elseif os(macOS)
            NSWorkspace.shared.open(url)
            #endif
        }
    }
}

// MARK: - Supporting Views
struct StatCard: View {
    let value: String
    let label: String
    let theme: ThemeColors
    var accentColor: Color?
    
    var body: some View {
        CardView(theme: theme) {
            VStack(spacing: 0) {
                Text(value)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(accentColor ?? theme.accent)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(theme.textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }
}

struct HeatMapCell: View {
    let category: Category
    let count: Int
    let maxCount: Int
    let theme: ThemeColors
    
    private var intensity: Double {
        guard maxCount > 0 else { return 0 }
        return Double(count) / Double(maxCount)
    }
    
    var body: some View {
        VStack(spacing: 3) {
            Text(category.icon)
                .font(.system(size: 18))
            
            Text(category.label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(count > 0 ? category.colorValue : theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text("\(count)")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(count > 0 ? theme.text : theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(count > 0 ? category.colorValue.opacity(intensity * 0.5 + 0.1) : theme.bgInput)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(count > 0 ? category.colorValue.opacity(0.4) : theme.border, lineWidth: 1)
        )
        .shadow(color: intensity > 0.6 ? category.colorValue.opacity(0.2) : .clear, radius: 6, x: 0, y: 0)
    }
}
