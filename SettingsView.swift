import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    @ObservedObject var subscriptionManager: SubscriptionManager
    
    @State private var selectedTab = "general"
    @State private var editingCategoryId: String?
    @State private var editingTeamId: String?
    @State private var showResetAlert = false
    @State private var showImportPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("⚙️ Settings")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(theme.accent)
            
            // Tabs
            HStack(spacing: 4) {
                ForEach(["general", "categories", "teams", "data"], id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.capitalized)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(selectedTab == tab ? theme.accent : theme.textMuted)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 7)
                            .background(selectedTab == tab ? theme.accentGlow : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedTab == tab ? theme.borderAccent : theme.border, lineWidth: 1)
                            )
                    }
                }
            }
            
            // Content
            ScrollView {
                switch selectedTab {
                case "general":
                    generalSettings
                case "categories":
                    categoriesSettings
                case "teams":
                    teamsSettings
                case "data":
                    dataSettings
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - General Settings
    private var generalSettings: some View {
        VStack(spacing: 14) {
            // Subscription Status
            subscriptionCard
            
            // Theme
            CardView(theme: theme) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionLabel(text: "🎨 THEME", theme: theme)
                    
                    HStack(spacing: 8) {
                        ForEach(AppTheme.allCases, id: \.self) { themeOption in
                            Button(action: { store.theme = themeOption; store.save() }) {
                                Text(themeOption.displayName)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(store.theme == themeOption ? ThemeColors.colors(for: themeOption).accent : theme.textSoft)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 8)
                                    .background(store.theme == themeOption ? ThemeColors.colors(for: themeOption).accentGlow : theme.bgInput)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(store.theme == themeOption ? ThemeColors.colors(for: themeOption).accent : theme.border, lineWidth: store.theme == themeOption ? 2 : 1)
                                    )
                            }
                        }
                    }
                }
                .padding(16)
            }
            
            // Duration settings
            CardView(theme: theme) {
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: "⏱️ DURATION MAX", theme: theme)
                    TextField("Max", value: Binding(
                        get: { store.durationSettings.max },
                        set: { store.durationSettings.max = $0; store.save() }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .padding(11)
                    .background(theme.bgInput)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.border, lineWidth: 1.5)
                    )
                    
                    SectionLabel(text: "⏱️ INCREMENT", theme: theme)
                    TextField("Increment", value: Binding(
                        get: { store.durationSettings.increment },
                        set: { store.durationSettings.increment = $0; store.save() }
                    ), format: .number)
                    .keyboardType(.numberPad)
                    .padding(11)
                    .background(theme.bgInput)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.border, lineWidth: 1.5)
                    )
                }
                .padding(16)
            }
            
            // Follow-up options
            CardView(theme: theme) {
                VStack(alignment: .leading, spacing: 6) {
                    SectionLabel(text: "📅 FOLLOW-UP OPTIONS", theme: theme)
                    
                    ForEach(Array(store.followups.enumerated()), id: \.element.id) { index, followup in
                        HStack(spacing: 6) {
                            TextField("Label", text: Binding(
                                get: { followup.label },
                                set: { store.followups[index].label = $0; store.save() }
                            ))
                            .padding(11)
                            .background(theme.bgInput)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(theme.border, lineWidth: 1.5)
                            )
                            
                            TextField("Hours", value: Binding(
                                get: { followup.hours },
                                set: { store.followups[index].hours = $0; store.save() }
                            ), format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 70)
                            .padding(11)
                            .background(theme.bgInput)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(theme.border, lineWidth: 1.5)
                            )
                            
                            Button(action: {
                                store.followups.remove(at: index)
                                store.save()
                            }) {
                                Text("✕")
                                    .font(.system(size: 16))
                                    .foregroundColor(theme.danger)
                                    .frame(width: 30)
                            }
                        }
                    }
                    
                    Button(action: {
                        store.followups.append(FollowupOption(label: "New", hours: 24))
                        store.save()
                    }) {
                        Text("+ Add")
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
                }
                .padding(16)
            }
            
            // Legal Links
            CardView(theme: theme) {
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel(text: "📄 LEGAL & SUPPORT", theme: theme)
                    
                    Link(destination: URL(string: "https://ssewalker-afk.github.io/leadership-notes/support.html")!) {
                        HStack {
                            Text("Support & Help")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.text)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(theme.accent)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .background(theme.border)
                    
                    Link(destination: URL(string: "https://ssewalker-afk.github.io/leadership-notes/privacy-policy.html")!) {
                        HStack {
                            Text("Privacy Policy")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.text)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(theme.accent)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .background(theme.border)
                    
                    Link(destination: URL(string: "https://ssewalker-afk.github.io/leadership-notes/terms-of-service.html")!) {
                        HStack {
                            Text("Terms of Service")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(theme.text)
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(theme.accent)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Divider()
                        .background(theme.border)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("App Version")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(theme.textMuted)
                        Text("1.0.0")
                            .font(.system(size: 15))
                            .foregroundColor(theme.text)
                    }
                    .padding(.vertical, 4)
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - Categories Settings
    private var categoriesSettings: some View {
        VStack(spacing: 14) {
            ForEach(store.categories) { category in
                if editingCategoryId == category.id {
                    EditCategoryCard(
                        category: binding(for: category),
                        theme: theme,
                        onDone: { editingCategoryId = nil },
                        onDelete: {
                            store.categories.removeAll { $0.id == category.id }
                            store.save()
                            editingCategoryId = nil
                        }
                    )
                } else {
                    CategoryDisplayCard(
                        category: category,
                        theme: theme,
                        onEdit: { editingCategoryId = category.id },
                        onDelete: {
                            store.categories.removeAll { $0.id == category.id }
                            store.save()
                        }
                    )
                }
            }
            
            Button(action: {
                let newCategory = Category(
                    id: UUID().uuidString,
                    label: "New",
                    icon: "📌",
                    color: "888888",
                    hasSubType: false,
                    hasDuration: false,
                    hasNotice: false
                )
                store.categories.append(newCategory)
                store.save()
                editingCategoryId = newCategory.id
            }) {
                Text("+ Add Category")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.gradient)
                    .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Teams Settings
    private var teamsSettings: some View {
        VStack(spacing: 14) {
            ForEach(store.teams) { team in
                if editingTeamId == team.id {
                    EditTeamCard(
                        team: binding(for: team),
                        theme: theme,
                        onDone: { editingTeamId = nil }
                    )
                } else {
                    TeamDisplayCard(
                        team: team,
                        peopleCount: store.people.filter { $0.teamId == team.id }.count,
                        theme: theme,
                        onToggle: {
                            if let index = store.teams.firstIndex(where: { $0.id == team.id }) {
                                store.teams[index].active.toggle()
                                store.save()
                            }
                        },
                        onEdit: { editingTeamId = team.id }
                    )
                }
            }
        }
    }
    
    // MARK: - Data Settings
    private var dataSettings: some View {
        VStack(spacing: 14) {
            CardView(theme: theme) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("🔒 All data stored on your device. Nothing leaves your phone.")
                        .font(.system(size: 13))
                        .foregroundColor(theme.textSoft)
                        .lineSpacing(3)
                    
                    Text("\(store.entries.count) entries • \(store.people.count) people")
                        .font(.system(size: 12))
                        .foregroundColor(theme.textMuted)
                    
                    Button(action: exportData) {
                        Text("💾 Backup")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.gradient)
                            .cornerRadius(12)
                    }
                    
                    Button(action: { showImportPicker = true }) {
                        Text("📂 Import")
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
                    .fileImporter(isPresented: $showImportPicker, allowedContentTypes: [.json]) { result in
                        importData(result: result)
                    }
                    
                    // Archive by year
                    VStack(alignment: .leading, spacing: 6) {
                        SectionLabel(text: "📦 ARCHIVE YEAR", theme: theme)
                        
                        let years = Array(Set(store.entries.map { Calendar.current.component(.year, from: $0.timestamp) })).sorted()
                        
                        if years.isEmpty {
                            Text("No entries")
                                .font(.system(size: 12))
                                .foregroundColor(theme.textMuted)
                        } else {
                            FlowLayout(spacing: 6) {
                                ForEach(years, id: \.self) { year in
                                    Button(action: { archiveYear(year) }) {
                                        let count = store.entries.filter { Calendar.current.component(.year, from: $0.timestamp) == year }.count
                                        Text("📦 \(year) (\(count))")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(theme.accent)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(theme.accentGlow)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(theme.borderAccent, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    
                    Button(action: { showResetAlert = true }) {
                        Text("☢️ Nuclear Reset")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundColor(theme.danger)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(theme.dangerBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.danger.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .alert("☢️ DELETE EVERYTHING?", isPresented: $showResetAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete All", role: .destructive) {
                            store.resetAll()
                            showToast("☢️ Reset complete")
                        }
                    } message: {
                        Text("This will permanently delete all entries, people, and custom settings. This cannot be undone.")
                    }
                }
                .padding(16)
            }
        }
    }
    
    // MARK: - Helpers
    private func binding<T: Identifiable & Equatable>(for item: T) -> Binding<T> where T == Category {
        Binding(
            get: { item },
            set: { newValue in
                if let index = store.categories.firstIndex(where: { $0.id == item.id }) {
                    store.categories[index] = newValue
                    store.save()
                }
            }
        )
    }
    
    private func binding<T: Identifiable & Equatable>(for item: T) -> Binding<T> where T == Team {
        Binding(
            get: { item },
            set: { newValue in
                if let index = store.teams.firstIndex(where: { $0.id == item.id }) {
                    store.teams[index] = newValue
                    store.save()
                }
            }
        )
    }
    
    // MARK: - Actions
    private func exportData() {
        guard let data = store.exportData() else {
            showToast("Export failed")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let filename = "leadership-notes-\(dateString).json"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
            showToast("💾 Downloaded!")
        } catch {
            showToast("Export failed")
        }
    }
    
    private func importData(result: Result<URL, Error>) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: url)
            try store.importData(data)
            showToast("📂 Imported!")
        } catch {
            showToast("Import failed")
        }
    }
    
    private func archiveYear(_ year: Int) {
        let yearEntries = store.entries.filter { Calendar.current.component(.year, from: $0.timestamp) == year }
        
        guard !yearEntries.isEmpty else {
            showToast("No entries for \(year)")
            return
        }
        
        // Generate archive text
        var lines: [String] = []
        lines.append("ARCHIVE \(year)")
        lines.append("\(yearEntries.count) entries\n")
        
        for entry in yearEntries {
            let category = store.categories.first { $0.id == entry.category }
            var line = "\(entry.timestamp.shortDate()) | \(entry.personName) | \(category?.label ?? "")"
            if let subType = entry.subType {
                line += " (\(subType))"
            }
            if let duration = entry.duration {
                line += " \(duration)min"
            }
            if !entry.notes.isEmpty {
                line += " - \(entry.notes)"
            }
            lines.append(line)
        }
        
        let body = lines.joined(separator: "\n")
        let subject = "Leadership Notes Archive \(year)"
        
        if let encoded = "mailto:?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            UIApplication.shared.open(url)
        }
        
        _ = store.archiveYear(year)
        showToast("📦 \(year) archived!")
    }
}

// MARK: - Category Cards
struct CategoryDisplayCard: View {
    let category: Category
    let theme: ThemeColors
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        CardView(theme: theme) {
            HStack {
                HStack(spacing: 8) {
                    Text(category.icon)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.label)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(category.colorValue)
                        
                        let features = [
                            category.hasDuration ? "Duration" : nil,
                            category.hasNotice ? "Notice" : nil,
                            category.hasSubType ? (category.subTypes ?? []).joined(separator: "/") : nil
                        ].compactMap { $0 }
                        
                        Text(features.isEmpty ? "Basic" : features.joined(separator: " • "))
                            .font(.system(size: 10))
                            .foregroundColor(theme.textMuted)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Edit", action: onEdit)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.accent)
                    
                    Button(action: { showDeleteAlert = true }) {
                        Text("✕")
                            .font(.system(size: 12))
                            .foregroundColor(theme.danger)
                    }
                    .alert("Delete \(category.label)?", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive, action: onDelete)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct EditCategoryCard: View {
    @Binding var category: Category
    let theme: ThemeColors
    let onDone: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        CardView(theme: theme) {
            VStack(alignment: .leading, spacing: 8) {
                TextField("Name", text: $category.label)
                    .textFieldStyle(ThemedTextFieldStyle(theme: theme))
                
                TextField("Emoji", text: $category.icon)
                    .textFieldStyle(ThemedTextFieldStyle(theme: theme))
                
                ColorPicker("Color", selection: Binding(
                    get: { category.colorValue },
                    set: { category.color = $0.toHex() }
                ))
                .padding(11)
                .background(theme.bgInput)
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Duration", isOn: $category.hasDuration)
                    Toggle("Notice", isOn: $category.hasNotice)
                    Toggle("Sub-types", isOn: $category.hasSubType)
                }
                .font(.system(size: 12))
                
                if category.hasSubType {
                    TextField("Sub-types (comma separated)", text: Binding(
                        get: { (category.subTypes ?? []).joined(separator: ", ") },
                        set: { category.subTypes = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    ))
                    .textFieldStyle(ThemedTextFieldStyle(theme: theme))
                }
                
                Button(action: onDone) {
                    Text("Done")
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
            }
            .padding(16)
        }
    }
}

// MARK: - Team Cards
struct TeamDisplayCard: View {
    let team: Team
    let peopleCount: Int
    let theme: ThemeColors
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        CardView(theme: theme) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(team.active ? theme.text : theme.textMuted)
                    
                    Text("\(team.active ? "Active" : "Inactive") • \(peopleCount) people")
                        .font(.system(size: 11))
                        .foregroundColor(team.active ? theme.accent : theme.textMuted)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(team.active ? "Deactivate" : "Activate", action: onToggle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(team.active ? theme.danger : theme.accent)
                    
                    Button("Rename", action: onEdit)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.accent)
                }
            }
            .padding(16)
        }
    }
}

struct EditTeamCard: View {
    @Binding var team: Team
    let theme: ThemeColors
    let onDone: () -> Void
    
    var body: some View {
        CardView(theme: theme) {
            VStack(spacing: 8) {
                TextField("Team Name", text: $team.name)
                    .textFieldStyle(ThemedTextFieldStyle(theme: theme))
                
                Button(action: onDone) {
                    Text("Done")
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
            }
            .padding(16)
        }
    }
}

// MARK: - Subscription Card
extension SettingsView {
    @ViewBuilder
    private var subscriptionCard: some View {
        CardView(theme: theme) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        SectionLabel(text: "💳 SUBSCRIPTION", theme: theme)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(subscriptionManager.isSubscribed ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            
                            Text(statusText)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(theme.text)
                        }
                    }
                    
                    Spacer()
                }
                
                if subscriptionManager.isSubscribed {
                    VStack(alignment: .leading, spacing: 8) {
                        if subscriptionManager.subscriptionStatus == .inFreeTrial {
                            Text("🎉 You're in your free trial period")
                                .font(.system(size: 13))
                                .foregroundColor(theme.textSoft)
                        } else {
                            Text("✓ All features unlocked")
                                .font(.system(size: 13))
                                .foregroundColor(theme.textSoft)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Manage Subscription")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(theme.accent)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start your 7-day free trial")
                            .font(.system(size: 13))
                            .foregroundColor(theme.textSoft)
                        
                        Text("\(subscriptionManager.displayPrice)/month after trial")
                            .font(.system(size: 12))
                            .foregroundColor(theme.textMuted)
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var statusText: String {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed:
            return "Active"
        case .inFreeTrial:
            return "Free Trial"
        case .expired:
            return "Expired"
        case .notSubscribed:
            return "Not Subscribed"
        case .unknown:
            return "Checking..."
        }
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
