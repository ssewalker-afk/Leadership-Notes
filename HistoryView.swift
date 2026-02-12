import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    let navigateToEntry: (Entry) -> Void
    
    @State private var filterPerson = "all"
    @State private var filterCategory = "all"
    @State private var filterTeam = "all"
    @State private var searchQuery = ""
    @State private var expandedEntryId: String?
    
    private var filteredEntries: [Entry] {
        store.entries.filter { entry in
            if filterPerson != "all" && entry.personId != filterPerson {
                return false
            }
            
            if filterCategory != "all" && entry.category != filterCategory {
                return false
            }
            
            if filterTeam != "all" {
                guard let person = store.people.first(where: { $0.id == entry.personId }),
                      person.teamId == filterTeam else {
                    return false
                }
            }
            
            if !searchQuery.isEmpty {
                let search = searchQuery.lowercased()
                let searchable = "\(entry.personName) \(entry.notes) \(entry.subType ?? "")".lowercased()
                if !searchable.contains(search) {
                    return false
                }
            }
            
            return true
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("📋 History")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(theme.accent)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(theme.textMuted)
                TextField("Search...", text: $searchQuery)
            }
            .padding(11)
            .background(theme.bgInput)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.border, lineWidth: 1.5)
            )
            
            // Filters
            HStack(spacing: 6) {
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
                .frame(maxWidth: .infinity)
                
                Picker("Category", selection: $filterCategory) {
                    Text("All Categories").tag("all")
                    ForEach(store.categories) { category in
                        Text("\(category.icon) \(category.label)").tag(category.id)
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
                .frame(maxWidth: .infinity)
            }
            
            Text("\(filteredEntries.count) entries")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(theme.textMuted)
            
            // Entries
            if filteredEntries.isEmpty {
                VStack {
                    Spacer()
                    Text(store.entries.isEmpty ? "No entries yet ⚡" : "No matches")
                        .foregroundColor(theme.textMuted)
                        .padding(40)
                    Spacer()
                }
            } else {
                ForEach(filteredEntries) { entry in
                    EntryCard(
                        entry: entry,
                        category: store.categories.first { $0.id == entry.category },
                        isExpanded: expandedEntryId == entry.id,
                        theme: theme,
                        onTap: { expandedEntryId = expandedEntryId == entry.id ? nil : entry.id },
                        onEdit: { navigateToEntry(entry) },
                        onDelete: {
                            store.deleteEntry(entry)
                            showToast("🗑️ Deleted")
                        }
                    )
                }
            }
        }
    }
}

struct EntryCard: View {
    let entry: Entry
    let category: Category?
    let isExpanded: Bool
    let theme: ThemeColors
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.personName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.text)
                        
                        HStack(spacing: 5) {
                            if let category = category {
                                CategoryBadge(category: category, small: true)
                            }
                            
                            if let subType = entry.subType {
                                Text(subType)
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.textSoft)
                            }
                            
                            if let duration = entry.duration {
                                Text("⏱️\(duration)m")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(theme.warn)
                            }
                            
                            if entry.notice == true {
                                Text("📢")
                                    .font(.system(size: 10))
                            }
                            
                            if entry.notice == false && category?.hasNotice == true {
                                Text("🚫")
                                    .font(.system(size: 10))
                            }
                            
                            if entry.followup != nil {
                                Text("📅")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(entry.timestamp.shortDate())
                            .font(.system(size: 10))
                            .foregroundColor(theme.textMuted)
                        Text(entry.timestamp.shortTime())
                            .font(.system(size: 10))
                            .foregroundColor(theme.textMuted)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                
                if isExpanded {
                    VStack(alignment: .leading, spacing: 8) {
                        Rectangle()
                            .fill(theme.border)
                            .frame(height: 1)
                        
                        if !entry.notes.isEmpty {
                            Text(entry.notes)
                                .font(.system(size: 13))
                                .foregroundColor(theme.textSoft)
                                .lineSpacing(3)
                        }
                        
                        if let followup = entry.followup {
                            Text("📅 Follow-up: \(followup.due.shortDate())")
                                .font(.system(size: 12))
                                .foregroundColor(theme.warn)
                        }
                        
                        HStack(spacing: 8) {
                            Button(action: onEdit) {
                                Text("✏️ Edit")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(theme.accent)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(theme.accentGlow)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(theme.borderAccent, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: { showDeleteAlert = true }) {
                                Text("🗑️")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(theme.danger)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(theme.dangerBg)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(theme.danger.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 11)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.bgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.border, lineWidth: 1)
            )
            .overlay(
                Rectangle()
                    .fill(category?.colorValue ?? .gray)
                    .frame(width: 3)
                    .cornerRadius(2),
                alignment: .leading
            )
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}
