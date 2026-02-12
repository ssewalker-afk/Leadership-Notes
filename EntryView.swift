import SwiftUI

import SwiftUI

struct EntryView: View {
    @ObservedObject var store: AppStore
    let theme: ThemeColors
    let showToast: (String) -> Void
    
    @State private var selectedPersonId: String?
    @State private var selectedCategoryId: String = ""
    @State private var selectedSubType: String?
    @State private var duration: Int?
    @State private var notice: Bool?
    @State private var followupHours: Int?
    @State private var notes: String = ""
    @State private var editingEntryId: String?
    
    @State private var showAddPerson = false
    @State private var newPersonName = ""
    @State private var newPersonTeam = "t1"
    
    private var selectedCategory: Category? {
        store.categories.first { $0.id == selectedCategoryId }
    }
    
    private var activeTeams: [Team] {
        store.teams.filter { $0.active }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(editingEntryId != nil ? "✏️ Edit Entry" : "⚡ Quick Entry")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(theme.accent)
            
            // Person selection
            personSection
            
            // Category selection
            categorySection
            
            // Sub-type
            if selectedCategory?.hasSubType == true {
                subTypeSection
            }
            
            // Duration
            if selectedCategory?.hasDuration == true {
                durationSection
            }
            
            // Notice
            if selectedCategory?.hasNotice == true && selectedCategory?.alwaysNoNotice != true {
                noticeSection
            }
            
            // Follow-up
            followupSection
            
            // Notes
            notesSection
            
            // Save button
            Button(action: saveEntry) {
                Text(editingEntryId != nil ? "✏️ Update" : "⚡ Save Entry")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.gradient)
                    .cornerRadius(12)
            }
            
            if editingEntryId != nil {
                Button(action: resetForm) {
                    Text("Cancel")
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
        }
    }
    
    // MARK: - Person Section
    private var personSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "👤 PERSON", theme: theme)
            
            if store.people.isEmpty && !showAddPerson {
                Button(action: { showAddPerson = true }) {
                    Text("+ Add First Person")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.gradient)
                        .cornerRadius(12)
                }
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(store.people) { person in
                        PersonButton(
                            person: person,
                            isSelected: selectedPersonId == person.id,
                            theme: theme
                        ) {
                            selectedPersonId = person.id
                        }
                    }
                    
                    Button(action: { showAddPerson.toggle() }) {
                        Text("+ Add")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(theme.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(Color.clear)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(theme.borderAccent, style: StrokeStyle(lineWidth: 1, dash: [4]))
                            )
                    }
                }
                
                if showAddPerson {
                    CardView(theme: theme) {
                        VStack(spacing: 8) {
                            TextField("Name...", text: $newPersonName)
                                .textFieldStyle(ThemedTextFieldStyle(theme: theme))
                            
                            Picker("Team", selection: $newPersonTeam) {
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
                            
                            HStack(spacing: 8) {
                                Button(action: addPerson) {
                                    Text("Add")
                                        .font(.system(size: 15, weight: .heavy))
                                        .foregroundColor(store.theme == .light ? .white : Color(hex: "001a1a"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(theme.gradient)
                                        .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    showAddPerson = false
                                    newPersonName = ""
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
                    }
                }
            }
        }
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "📂 CATEGORY", theme: theme)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
                ForEach(store.categories) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategoryId == category.id,
                        theme: theme
                    ) {
                        selectedCategoryId = category.id
                        selectedSubType = nil
                        duration = nil
                        notice = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Sub-type Section
    private var subTypeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "\(selectedCategory?.label ?? "") — TYPE", theme: theme)
            
            HStack(spacing: 8) {
                ForEach(selectedCategory?.subTypes ?? [], id: \.self) { subType in
                    Button(action: { selectedSubType = subType }) {
                        Text(subType)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(selectedSubType == subType ? selectedCategory?.colorValue : theme.textSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(selectedSubType == subType ? (selectedCategory?.colorValue.opacity(0.18) ?? theme.bgInput) : theme.bgInput)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedSubType == subType ? (selectedCategory?.colorValue ?? theme.border) : theme.border, lineWidth: selectedSubType == subType ? 2 : 1)
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Duration Section
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "⏱️ DURATION (MINUTES)", theme: theme)
            
            DurationPicker(
                value: $duration,
                settings: store.durationSettings,
                theme: theme
            )
        }
    }
    
    // MARK: - Notice Section
    private var noticeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "📢 NOTICE GIVEN?", theme: theme)
            
            Toggle2(value: $notice, labelA: "Yes 📢", labelB: "No 🚫", theme: theme)
        }
    }
    
    // MARK: - Follow-up Section
    private var followupSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "📅 FOLLOW-UP?", theme: theme)
            
            if followupHours == nil {
                Button(action: { followupHours = store.followups.first?.hours ?? 24 }) {
                    Text("+ Add Follow-up")
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
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    FlowLayout(spacing: 6) {
                        ForEach(store.followups) { followup in
                            Button(action: { followupHours = followup.hours }) {
                                Text(followup.label)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(followupHours == followup.hours ? theme.warn : theme.textMuted)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(followupHours == followup.hours ? theme.warnBg : theme.bgInput)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(followupHours == followup.hours ? theme.warn : theme.border, lineWidth: followupHours == followup.hours ? 2 : 1)
                                    )
                            }
                        }
                    }
                    
                    Button(action: { followupHours = nil }) {
                        Text("✕ Remove")
                            .font(.system(size: 12))
                            .foregroundColor(theme.textMuted)
                    }
                }
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionLabel(text: "📝 NOTES (OPTIONAL)", theme: theme)
            
            TextEditor(text: $notes)
                .frame(height: 80)
                .padding(8)
                .background(theme.bgInput)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.border, lineWidth: 1.5)
                )
                .scrollContentBackground(.hidden)
        }
    }
    
    // MARK: - Actions
    private func addPerson() {
        guard !newPersonName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let person = Person(name: newPersonName.trimmingCharacters(in: .whitespaces), teamId: newPersonTeam)
        store.addPerson(person)
        selectedPersonId = person.id
        newPersonName = ""
        showAddPerson = false
        showToast("👋 \(person.name) added!")
    }
    
    private func saveEntry() {
        guard let personId = selectedPersonId,
              !selectedCategoryId.isEmpty,
              let person = store.people.first(where: { $0.id == personId }) else {
            showToast("⚡ Pick person & category!")
            return
        }
        
        if selectedCategory?.hasSubType == true && selectedSubType == nil {
            showToast("⚡ Pick a type!")
            return
        }
        
        let followup: Followup? = followupHours.map { hours in
            Followup(hours: hours, due: Date().addingTimeInterval(TimeInterval(hours * 3600)))
        }
        
        let finalNotice = selectedCategory?.alwaysNoNotice == true ? false : notice
        
        if let editId = editingEntryId,
           let existing = store.entries.first(where: { $0.id == editId }) {
            let updated = Entry(
                id: editId,
                personId: personId,
                personName: person.name,
                category: selectedCategoryId,
                subType: selectedSubType,
                duration: duration,
                notice: finalNotice,
                followup: followup,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                timestamp: existing.timestamp
            )
            store.updateEntry(updated)
            showToast("✏️ Updated!")
        } else {
            let entry = Entry(
                personId: personId,
                personName: person.name,
                category: selectedCategoryId,
                subType: selectedSubType,
                duration: duration,
                notice: finalNotice,
                followup: followup,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            store.addEntry(entry)
            showToast("⚡ Logged!")
        }
        
        resetForm()
    }
    
    private func resetForm() {
        selectedPersonId = nil
        selectedCategoryId = ""
        selectedSubType = nil
        duration = nil
        notice = nil
        followupHours = nil
        notes = ""
        editingEntryId = nil
    }
    
    func loadEntry(_ entry: Entry) {
        editingEntryId = entry.id
        selectedPersonId = entry.personId
        selectedCategoryId = entry.category
        selectedSubType = entry.subType
        duration = entry.duration
        notice = entry.notice
        followupHours = entry.followup?.hours
        notes = entry.notes
    }
}
