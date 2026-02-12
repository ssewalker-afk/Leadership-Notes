import SwiftUI

import SwiftUI
import Combine

@MainActor
class AppStore: ObservableObject {
    @Published var entries: [Entry] = []
    @Published var people: [Person] = []
    @Published var categories: [Category] = Category.defaults
    @Published var teams: [Team] = Team.defaults
    @Published var followups: [FollowupOption] = FollowupOption.defaults
    @Published var durationSettings: DurationSettings = .default
    @Published var theme: AppTheme = .light
    
    private let entriesKey = "ln-e"
    private let peopleKey = "ln-p"
    private let categoriesKey = "ln-c"
    private let teamsKey = "ln-t"
    private let followupsKey = "ln-f"
    private let durationKey = "ln-d"
    private let themeKey = "ln-theme"
    
    init() {
        load()
    }
    
    // MARK: - Persistence
    private func load() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([Entry].self, from: data) {
            entries = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: peopleKey),
           let decoded = try? JSONDecoder().decode([Person].self, from: data) {
            people = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let decoded = try? JSONDecoder().decode([Category].self, from: data) {
            categories = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: teamsKey),
           let decoded = try? JSONDecoder().decode([Team].self, from: data) {
            teams = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: followupsKey),
           let decoded = try? JSONDecoder().decode([FollowupOption].self, from: data) {
            followups = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: durationKey),
           let decoded = try? JSONDecoder().decode(DurationSettings.self, from: data) {
            durationSettings = decoded
        }
        
        if let themeString = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: themeString) {
            self.theme = theme
        }
    }
    
    func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
        
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: peopleKey)
        }
        
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
        
        if let encoded = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(encoded, forKey: teamsKey)
        }
        
        if let encoded = try? JSONEncoder().encode(followups) {
            UserDefaults.standard.set(encoded, forKey: followupsKey)
        }
        
        if let encoded = try? JSONEncoder().encode(durationSettings) {
            UserDefaults.standard.set(encoded, forKey: durationKey)
        }
        
        UserDefaults.standard.set(theme.rawValue, forKey: themeKey)
    }
    
    // MARK: - Entry Methods
    func addEntry(_ entry: Entry) {
        entries.insert(entry, at: 0)
        save()
    }
    
    func updateEntry(_ entry: Entry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            save()
        }
    }
    
    func deleteEntry(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
    
    // MARK: - Person Methods
    func addPerson(_ person: Person) {
        people.append(person)
        save()
    }
    
    func updatePerson(_ person: Person) {
        if let index = people.firstIndex(where: { $0.id == person.id }) {
            people[index] = person
            save()
        }
    }
    
    func deletePerson(_ person: Person) {
        people.removeAll { $0.id == person.id }
        entries.removeAll { $0.personId == person.id }
        save()
    }
    
    // MARK: - Reminders
    func reminders() -> [Reminder] {
        var results: [Reminder] = []
        let now = Date()
        
        // Important dates
        for person in people {
            for date in person.dates {
                let reminderHours: Double = {
                    switch date.remind {
                    case "48 hours": return 48
                    case "1 week": return 168
                    case "2 weeks": return 336
                    default: return 168
                    }
                }()
                
                var targetDate = date.date
                if date.recurring {
                    let calendar = Calendar.current
                    let year = calendar.component(.year, from: now)
                    var components = calendar.dateComponents([.month, .day], from: date.date)
                    components.year = year
                    if let newDate = calendar.date(from: components) {
                        targetDate = newDate
                        if newDate < now {
                            components.year = year + 1
                            targetDate = calendar.date(from: components) ?? targetDate
                        }
                    }
                }
                
                let hoursUntil = targetDate.timeIntervalSince(now) / 3600
                if hoursUntil > 0 && hoursUntil <= reminderHours {
                    results.append(Reminder(
                        person: person.name,
                        label: date.label,
                        days: max(0, Int(ceil(hoursUntil / 24))),
                        isFollowup: false
                    ))
                }
            }
        }
        
        // Follow-ups
        for entry in entries {
            if let followup = entry.followup {
                let hoursUntil = followup.due.timeIntervalSince(now) / 3600
                if hoursUntil > -24 && hoursUntil < 48 {
                    let category = categories.first { $0.id == entry.category }
                    results.append(Reminder(
                        person: entry.personName,
                        label: "Follow-up: \(category?.label ?? "")",
                        days: max(0, Int(ceil(hoursUntil / 24))),
                        isFollowup: true
                    ))
                }
            }
        }
        
        return results.sorted { $0.days < $1.days }
    }
    
    // MARK: - Export/Import
    struct ExportData: Codable {
        let entries: [Entry]
        let people: [Person]
        let categories: [Category]
        let teams: [Team]
        let followups: [FollowupOption]
        let durSet: DurationSettings
        let theme: AppTheme
    }
    
    func exportData() -> Data? {
        let exportData = ExportData(
            entries: entries,
            people: people,
            categories: categories,
            teams: teams,
            followups: followups,
            durSet: durationSettings,
            theme: theme
        )
        return try? JSONEncoder().encode(exportData)
    }
    
    func importData(_ data: Data) throws {
        let imported = try JSONDecoder().decode(ExportData.self, from: data)
        entries = imported.entries
        people = imported.people
        categories = imported.categories
        teams = imported.teams
        followups = imported.followups
        durationSettings = imported.durSet
        theme = imported.theme
        save()
    }
    
    func resetAll() {
        entries = []
        people = []
        categories = Category.defaults
        teams = Team.defaults
        followups = FollowupOption.defaults
        durationSettings = .default
        save()
    }
    
    func archiveYear(_ year: Int) -> [Entry] {
        let calendar = Calendar.current
        let yearEntries = entries.filter { calendar.component(.year, from: $0.timestamp) == year }
        entries.removeAll { calendar.component(.year, from: $0.timestamp) == year }
        save()
        return yearEntries
    }
}
