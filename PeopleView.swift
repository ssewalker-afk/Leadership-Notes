import SwiftUI

struct PeopleView: View {
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    
    @State private var selectedPersonId: String?
    @State private var newPersonName = ""
    @State private var newPersonTeam = "t1"
    @State private var showTeamPicker = false
    
    private var activeTeams: [Team] {
        store.teams.filter { $0.active }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let personId = selectedPersonId {
                PersonDetailView(
                    personId: personId,
                    store: store,
                    theme: theme,
                    showToast: showToast,
                    onBack: { selectedPersonId = nil }
                )
            } else {
                peopleListView
            }
        }
    }
    
    // MARK: - People List
    private var peopleListView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("👥 People")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(theme.accent)
            
            // Add person
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    TextField("Name...", text: $newPersonName)
                        .padding(11)
                        .background(theme.bgInput)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(theme.border, lineWidth: 1.5)
                        )
                    
                    Button(action: { showTeamPicker = true }) {
                        HStack(spacing: 4) {
                            Text(store.teams.first { $0.id == newPersonTeam }?.name ?? "Team")
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(theme.text)
                        .padding(11)
                        .frame(minWidth: 90)
                        .background(theme.bgInput)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(theme.border, lineWidth: 1.5)
                        )
                    }
                    
                    Button(action: addPerson) {
                        Text("+")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                            .frame(width: 44, height: 44)
                            .background(theme.gradient)
                            .cornerRadius(10)
                    }
                }
                
                if activeTeams.isEmpty {
                    Text("⚠️ No active teams. Create one below.")
                        .font(.system(size: 12))
                        .foregroundColor(theme.warn)
                }
            }
            
            // People list
            if store.people.isEmpty {
                VStack {
                    Spacer()
                    Text("No people yet 👋")
                        .foregroundColor(theme.textMuted)
                        .padding(40)
                    Spacer()
                }
            } else {
                ForEach(store.people) { person in
                    PersonCard(
                        person: person,
                        team: store.teams.first { $0.id == person.teamId },
                        entryCount: store.entries.filter { $0.personId == person.id }.count,
                        theme: theme,
                        onTap: { selectedPersonId = person.id }
                    )
                }
            }
        }
        .sheet(isPresented: $showTeamPicker) {
            TeamPickerSheet(
                selectedTeamId: $newPersonTeam,
                store: store,
                theme: theme,
                showToast: showToast,
                onDismiss: { showTeamPicker = false }
            )
        }
    }
    
    // MARK: - Actions
    private func addPerson() {
        guard !newPersonName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let person = Person(
            name: newPersonName.trimmingCharacters(in: .whitespaces),
            teamId: newPersonTeam
        )
        store.addPerson(person)
        newPersonName = ""
        showToast("👋 \(person.name) added!")
    }
}

// MARK: - Person Card
struct PersonCard: View {
    let person: Person
    let team: Team?
    let entryCount: Int
    let theme: ThemeColors
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(theme.text)
                    
                    Text("\(team?.name ?? "No Team") • \(entryCount) entries • \(person.dates.count) dates")
                        .font(.system(size: 11))
                        .foregroundColor(theme.textMuted)
                }
                
                Spacer()
                
                Text("›")
                    .font(.system(size: 18))
                    .foregroundColor(theme.textMuted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.bgCard)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(theme.border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Person Detail View
struct PersonDetailView: View {
    let personId: String
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    let onBack: () -> Void
    
    @State private var showAddDate = false
    @State private var newDateLabel = ""
    @State private var newDate = Date()
    @State private var newDateRemind = "1 week"
    @State private var newDateRecurring = true
    @State private var showDeleteAlert = false
    @State private var showTeamPicker = false
    
    private var person: Person? {
        store.people.first { $0.id == personId }
    }
    
    private var activeTeams: [Team] {
        store.teams.filter { $0.active }
    }
    
    var body: some View {
        guard let person = person else {
            return AnyView(EmptyView())
        }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 14) {
                Button(action: onBack) {
                    Text("← Back")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.accent)
                }
                
                Text(person.name)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(theme.text)
                
                Text("\(store.teams.first { $0.id == person.teamId }?.name ?? "No Team") • \(store.entries.filter { $0.personId == person.id }.count) entries")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textMuted)
                
                // Team selection
                CardView(theme: theme) {
                    VStack(alignment: .leading, spacing: 6) {
                        SectionLabel(text: "TEAM", theme: theme)
                        
                        Button(action: { showTeamPicker = true }) {
                            HStack {
                                Text(store.teams.first { $0.id == person.teamId }?.name ?? "Select Team")
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.text)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(theme.textMuted)
                            }
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
                .sheet(isPresented: $showTeamPicker) {
                    TeamPickerSheet(
                        selectedTeamId: Binding(
                            get: { person.teamId },
                            set: { newTeamId in
                                var updated = person
                                updated.teamId = newTeamId
                                store.updatePerson(updated)
                            }
                        ),
                        store: store,
                        theme: theme,
                        showToast: showToast,
                        onDismiss: { showTeamPicker = false }
                    )
                }
                
                // Important dates
                importantDatesSection(person: person)
                
                // Delete button
                Button(action: { showDeleteAlert = true }) {
                    Text("☢️ Delete \(person.name) & All Entries")
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
                .alert("Delete \(person.name)?", isPresented: $showDeleteAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) {
                        store.deletePerson(person)
                        showToast("☢️ \(person.name) deleted")
                        onBack()
                    }
                } message: {
                    Text("This will delete \(person.name) and ALL their entries. Email their report first if you need records.")
                }
            }
        )
    }
    
    // MARK: - Important Dates Section
    private func importantDatesSection(person: Person) -> some View {
        CardView(theme: theme) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    SectionLabel(text: "📅 IMPORTANT DATES", theme: theme)
                    Spacer()
                    Button(action: { showAddDate = true }) {
                        Text("+ Add")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(theme.accent)
                    }
                }
                
                if person.dates.isEmpty && !showAddDate {
                    Text("No dates yet")
                        .font(.system(size: 13))
                        .foregroundColor(theme.textMuted)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                } else {
                    ForEach(person.dates) { date in
                        ImportantDateRow(
                            date: date,
                            theme: theme,
                            onDelete: {
                                var updated = person
                                updated.dates.removeAll { $0.id == date.id }
                                store.updatePerson(updated)
                                showToast("🗑️ Removed")
                            }
                        )
                    }
                }
                
                if showAddDate {
                    addDateForm(person: person)
                }
            }
            .padding(16)
        }
    }
    
    private func addDateForm(person: Person) -> some View {
        VStack(spacing: 8) {
            TextField("e.g. \"Birthday\", \"Forklift Cert\"", text: $newDateLabel)
                .padding(11)
                .background(theme.bgInput)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.border, lineWidth: 1.5)
                )
            
            DatePicker("Date", selection: $newDate, displayedComponents: .date)
                .padding(11)
                .background(theme.bgInput)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.border, lineWidth: 1.5)
                )
            
            Picker("Remind", selection: $newDateRemind) {
                Text("48 hours before").tag("48 hours")
                Text("1 week before").tag("1 week")
                Text("2 weeks before").tag("2 weeks")
            }
            .pickerStyle(.menu)
            .padding(11)
            .background(theme.bgInput)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.border, lineWidth: 1.5)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                SectionLabel(text: "YEARLY?", theme: theme)
                Toggle2(value: Binding(
                    get: { newDateRecurring ? true : false },
                    set: { newDateRecurring = $0 ?? true }
                ), labelA: "Yes 🔄", labelB: "No", theme: theme)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    addImportantDate(to: person)
                }) {
                    Text("Save")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.gradient)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showAddDate = false
                    newDateLabel = ""
                    newDate = Date()
                }) {
                    Text("✕")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(theme.accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(theme.accentGlow)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.borderAccent, lineWidth: 1)
                        )
                }
            }
        }
        .padding(12)
        .background(theme.bgInput)
        .cornerRadius(10)
    }
    
    private func addImportantDate(to person: Person) {
        guard !newDateLabel.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newImportantDate = ImportantDate(
            id: UUID().uuidString,
            label: newDateLabel.trimmingCharacters(in: .whitespaces),
            date: newDate,
            remind: newDateRemind,
            recurring: newDateRecurring
        )
        
        var updated = person
        updated.dates.append(newImportantDate)
        store.updatePerson(updated)
        
        newDateLabel = ""
        newDate = Date()
        showAddDate = false
        showToast("📅 Date saved!")
    }
}

// MARK: - Important Date Row
struct ImportantDateRow: View {
    let date: ImportantDate
    let theme: ThemeColors
    let onDelete: () -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(date.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.text)
                
                Text("\(date.date.shortDate()) • \(date.remind) • \(date.recurring ? "🔄 Yearly" : "One-time")")
                    .font(.system(size: 11))
                    .foregroundColor(theme.textMuted)
            }
            
            Spacer()
            
            Button(action: { showDeleteAlert = true }) {
                Text("✕")
                    .font(.system(size: 14))
                    .foregroundColor(theme.danger)
            }
            .alert("Delete this date?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive, action: onDelete)
            }
        }
        .padding(.vertical, 7)
        .overlay(
            Rectangle()
                .fill(theme.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}
// MARK: - Team Picker Sheet
struct TeamPickerSheet: View {
    @Binding var selectedTeamId: String
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    let onDismiss: () -> Void
    
    @State private var showCreateTeam = false
    @State private var newTeamName = ""
    @State private var editingTeamId: String?
    @State private var editingTeamName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 14) {
                        // Active teams section
                        if !store.teams.filter({ $0.active }).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionLabel(text: "ACTIVE TEAMS", theme: theme)
                                    .padding(.horizontal, 20)
                                
                                ForEach(store.teams.filter { $0.active }) { team in
                                    teamRow(team: team)
                                }
                            }
                        }
                        
                        // Inactive teams section
                        if !store.teams.filter({ !$0.active }).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                SectionLabel(text: "INACTIVE TEAMS", theme: theme)
                                    .padding(.horizontal, 20)
                                
                                ForEach(store.teams.filter { !$0.active }) { team in
                                    teamRow(team: team)
                                }
                            }
                        }
                        
                        // Create new team section
                        VStack(spacing: 8) {
                            if showCreateTeam {
                                CardView(theme: theme) {
                                    VStack(spacing: 8) {
                                        TextField("Team Name", text: $newTeamName)
                                            .padding(11)
                                            .background(theme.bgInput)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(theme.border, lineWidth: 1.5)
                                            )
                                        
                                        HStack(spacing: 8) {
                                            Button(action: createTeam) {
                                                Text("Create")
                                                    .font(.system(size: 15, weight: .heavy))
                                                    .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 14)
                                                    .background(theme.gradient)
                                                    .cornerRadius(12)
                                            }
                                            
                                            Button(action: {
                                                showCreateTeam = false
                                                newTeamName = ""
                                            }) {
                                                Text("Cancel")
                                                    .font(.system(size: 15, weight: .heavy))
                                                    .foregroundColor(theme.accent)
                                                    .padding(.horizontal, 18)
                                                    .padding(.vertical, 14)
                                                    .background(theme.accentGlow)
                                                    .cornerRadius(12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .stroke(theme.borderAccent, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(16)
                                }
                                .padding(.horizontal, 20)
                            } else {
                                Button(action: { showCreateTeam = true }) {
                                    Text("+ Create New Team")
                                        .font(.system(size: 15, weight: .heavy))
                                        .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(theme.gradient)
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Select Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(theme.accent)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    @ViewBuilder
    private func teamRow(team: Team) -> some View {
        if editingTeamId == team.id {
            // Edit mode
            CardView(theme: theme) {
                VStack(spacing: 8) {
                    TextField("Team Name", text: $editingTeamName)
                        .padding(11)
                        .background(theme.bgInput)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(theme.border, lineWidth: 1.5)
                        )
                    
                    HStack(spacing: 8) {
                        Button(action: { saveTeamName(team: team) }) {
                            Text("Save")
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
                        
                        Button(action: {
                            editingTeamId = nil
                            editingTeamName = ""
                        }) {
                            Text("Cancel")
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundColor(theme.textMuted)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(theme.bgInput)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 20)
        } else {
            // Display mode
            Button(action: {
                selectedTeamId = team.id
                showToast("✅ Team selected: \(team.name)")
            }) {
                CardView(theme: theme) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(team.active ? theme.text : theme.textMuted)
                            
                            HStack(spacing: 8) {
                                Text(team.active ? "Active" : "Inactive")
                                    .font(.system(size: 11))
                                    .foregroundColor(team.active ? theme.accent : theme.textMuted)
                                
                                Text("•")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.textMuted)
                                
                                Text("\(store.people.filter { $0.teamId == team.id }.count) people")
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.textMuted)
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            if selectedTeamId == team.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(theme.accent)
                            }
                            
                            Button(action: {
                                editingTeamId = team.id
                                editingTeamName = team.name
                            }) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14))
                                    .foregroundColor(theme.accent)
                                    .padding(8)
                                    .background(theme.accentGlow)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }
    
    private func createTeam() {
        guard !newTeamName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newTeam = Team(
            id: UUID().uuidString,
            name: newTeamName.trimmingCharacters(in: .whitespaces),
            active: true
        )
        store.teams.append(newTeam)
        store.save()
        
        selectedTeamId = newTeam.id
        showToast("✅ Team created: \(newTeam.name)")
        
        newTeamName = ""
        showCreateTeam = false
    }
    
    private func saveTeamName(team: Team) {
        guard !editingTeamName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        if let index = store.teams.firstIndex(where: { $0.id == team.id }) {
            store.teams[index].name = editingTeamName.trimmingCharacters(in: .whitespaces)
            store.save()
            showToast("✅ Team renamed")
        }
        
        editingTeamId = nil
        editingTeamName = ""
    }
}

