import SwiftUI

import SwiftUI
import PDFKit

struct ReportsView: View {
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var filterPerson = "all"
    @State private var filterTeam = "all"
    @State private var showPreview = false
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    
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
            Text("Reports")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.text)
            
            // Filters
            CardView(theme: theme) {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            SectionLabel(text: "START", theme: theme)
                            Text(startDate.shortDate())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(11)
                                .background(theme.bgInput)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(theme.border, lineWidth: 1.5)
                                )
                                .overlay(
                                    DatePicker("", selection: $startDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .blendMode(.destinationOver)
                                        .opacity(0.011)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            SectionLabel(text: "END", theme: theme)
                            Text(endDate.shortDate())
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(11)
                                .background(theme.bgInput)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(theme.border, lineWidth: 1.5)
                                )
                                .overlay(
                                    DatePicker("", selection: $endDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .blendMode(.destinationOver)
                                        .opacity(0.011)
                                )
                        }
                    }
                    
                    Picker("Person", selection: $filterPerson) {
                        Text("All Team Members").tag("all")
                        ForEach(store.people) { person in
                            Text(person.name).tag(person.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(theme.accent)
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
                        .tint(theme.accent)
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
                StatCard(value: "\(uniquePeopleCount)", label: "TEAM", theme: theme, accentColor: theme.warn)
            }
            
            // Heat map
            heatMap
            
            // Actions
            Button(action: shareReport) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Share Report")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(theme.gradient)
                .cornerRadius(12)
            }
            
            Button(action: { showPreview.toggle() }) {
                HStack {
                    Image(systemName: showPreview ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text(showPreview ? "Hide Preview" : "Preview Report")
                        .font(.system(size: 15, weight: .semibold))
                }
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
        .sheet(isPresented: $showShareSheet) {
            if let pdfURL = pdfURL {
                ShareSheet(items: [pdfURL])
            }
        }
    }
    
    // MARK: - Heat Map
    private var heatMap: some View {
        CardView(theme: theme) {
            VStack(alignment: .leading, spacing: 10) {
                Text("CATEGORY BREAKDOWN")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(theme.textMuted)
                    .tracking(0.5)
                
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
    
    private func shareReport() {
        // Generate PDF
        let personName = filterPerson != "all" ? (store.people.first { $0.id == filterPerson }?.name ?? "All") : "All Team Members"
        let fileName = "Leadership_Notes_\(personName)_\(startDate.formatted("yyyyMMdd"))-\(endDate.formatted("yyyyMMdd")).pdf"
        
        guard let pdfData = generatePDF() else {
            showToast("❌ Failed to generate PDF")
            return
        }
        
        // Save to temporary directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: tempURL)
            self.pdfURL = tempURL
            self.showShareSheet = true
        } catch {
            showToast("❌ Failed to save PDF")
        }
    }
    
    private func generatePDF() -> Data? {
        let reportText = generateReportText()
        let personName = filterPerson != "all" ? (store.people.first { $0.id == filterPerson }?.name ?? "All") : "All Team Members"
        let dateRange = "\(startDate.shortDate()) — \(endDate.shortDate())"
        
        // PDF format
        let format = UIGraphicsPDFRendererFormat()
        let pageWidth: CGFloat = 612 // 8.5 inches
        let pageHeight: CGFloat = 792 // 11 inches
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = margin
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.label
            ]
            let titleText = "Leadership Notes Report"
            let titleSize = titleText.size(withAttributes: titleAttributes)
            titleText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Date range
            let subtitleFont = UIFont.systemFont(ofSize: 14)
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.secondaryLabel
            ]
            dateRange.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 14 + 10
            
            // Person
            "\(personName)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += 14 + 20
            
            // Separator line
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: margin, y: yPosition))
            linePath.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            UIColor.separator.setStroke()
            linePath.lineWidth = 1
            linePath.stroke()
            yPosition += 20
            
            // Content
            let bodyFont = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.label
            ]
            
            let contentWidth = pageWidth - (margin * 2)
            let lines = reportText.components(separatedBy: "\n")
            
            for line in lines {
                let lineSize = line.size(withAttributes: bodyAttributes)
                
                // Check if we need a new page
                if yPosition + lineSize.height > pageHeight - margin {
                    context.beginPage()
                    yPosition = margin
                }
                
                line.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: lineSize.height),
                         withAttributes: bodyAttributes)
                yPosition += lineSize.height + 2
            }
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
        VStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(count > 0 ? category.colorValue : theme.textMuted)
            
            Text(category.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(count > 0 ? theme.text : theme.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text("\(count)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(count > 0 ? theme.text : theme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(count > 0 ? category.colorValue.opacity(intensity * 0.3 + 0.1) : theme.bgInput)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(count > 0 ? category.colorValue.opacity(0.3) : theme.border.opacity(0.5), lineWidth: 1)
        )
    }
}
// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to update
    }
}

