import Foundation
import SwiftUI

// MARK: - Theme
enum AppTheme: String, CaseIterable, Codable {
    case light, dark, rainbow
    
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .rainbow: return "Neon"
        }
    }
}

struct ThemeColors {
    let bg: Color
    let bgCard: Color
    let bgInput: Color
    let bgNav: Color
    let text: Color
    let textSoft: Color
    let textMuted: Color
    let accent: Color
    let accentGlow: Color
    let border: Color
    let borderAccent: Color
    let danger: Color
    let dangerBg: Color
    let warn: Color
    let warnBg: Color
    let gradient: LinearGradient
    
    static func colors(for theme: AppTheme) -> ThemeColors {
        switch theme {
        case .light:
            return ThemeColors(
                bg: Color(hex: "f5f5f7"),
                bgCard: .white,
                bgInput: Color(hex: "f5f5f7"),
                bgNav: .white,
                text: Color(hex: "1d1d1f"),
                textSoft: Color(hex: "6e6e73"),
                textMuted: Color(hex: "86868b"),
                accent: Color(hex: "2d6a4f"),
                accentGlow: Color(hex: "2d6a4f").opacity(0.1),
                border: Color(hex: "d2d2d7"),
                borderAccent: Color(hex: "2d6a4f").opacity(0.3),
                danger: Color(hex: "ff3b30"),
                dangerBg: Color(hex: "ff3b30").opacity(0.1),
                warn: Color(hex: "ff9500"),
                warnBg: Color(hex: "ff9500").opacity(0.08),
                gradient: LinearGradient(colors: [Color(hex: "2d6a4f"), Color(hex: "40916c")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .dark:
            return ThemeColors(
                bg: Color(hex: "000000"),
                bgCard: Color(hex: "1c1c1e"),
                bgInput: Color(hex: "2c2c2e"),
                bgNav: Color(hex: "1c1c1e"),
                text: Color(hex: "f5f5f7"),
                textSoft: Color(hex: "98989d"),
                textMuted: Color(hex: "636366"),
                accent: Color(hex: "52b788"),
                accentGlow: Color(hex: "52b788").opacity(0.15),
                border: Color(hex: "38383a"),
                borderAccent: Color(hex: "52b788").opacity(0.3),
                danger: Color(hex: "ff453a"),
                dangerBg: Color(hex: "ff453a").opacity(0.15),
                warn: Color(hex: "ff9f0a"),
                warnBg: Color(hex: "ff9f0a").opacity(0.15),
                gradient: LinearGradient(colors: [Color(hex: "52b788"), Color(hex: "40916c")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .rainbow:
            return ThemeColors(
                bg: Color(hex: "000000"),
                bgCard: Color(hex: "1c1c1e"),
                bgInput: Color(hex: "2c2c2e"),
                bgNav: Color(hex: "1c1c1e"),
                text: Color(hex: "f5f5f7"),
                textSoft: Color(hex: "98989d"),
                textMuted: Color(hex: "636366"),
                accent: Color(hex: "bf5af2"),
                accentGlow: Color(hex: "bf5af2").opacity(0.15),
                border: Color(hex: "38383a"),
                borderAccent: Color(hex: "bf5af2").opacity(0.3),
                danger: Color(hex: "ff453a"),
                dangerBg: Color(hex: "ff453a").opacity(0.15),
                warn: Color(hex: "ffd60a"),
                warnBg: Color(hex: "ffd60a").opacity(0.15),
                gradient: LinearGradient(colors: [Color(hex: "bf5af2"), Color(hex: "5e5ce6"), Color(hex: "0a84ff")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        }
    }
}

// MARK: - Category
struct Category: Identifiable, Codable, Equatable {
    let id: String
    var label: String
    var icon: String
    var color: String
    var hasSubType: Bool
    var subTypes: [String]?
    var hasDuration: Bool
    var hasNotice: Bool
    var alwaysNoNotice: Bool?
    
    var colorValue: Color {
        Color(hex: color)
    }
    
    static let defaults: [Category] = [
        Category(id: "arrival", label: "Arrival", icon: "figure.walk", color: "2d6a4f", hasSubType: true, subTypes: ["Late", "Early"], hasDuration: true, hasNotice: true),
        Category(id: "lunch", label: "Lunch", icon: "fork.knife", color: "e67e22", hasSubType: true, subTypes: ["Early", "Late"], hasDuration: true, hasNotice: true),
        Category(id: "early_out", label: "Early Out", icon: "door.left.hand.open", color: "ff7b54", hasSubType: true, subTypes: ["No Notice", "Short Notice"], hasDuration: true, hasNotice: false),
        Category(id: "no_show", label: "No Show", icon: "person.fill.xmark", color: "d63031", hasSubType: true, subTypes: ["No Notice", "Short Notice"], hasDuration: false, hasNotice: false),
        Category(id: "missing", label: "Missing", icon: "person.fill.questionmark", color: "8e44ad", hasSubType: false, hasDuration: true, hasNotice: true),
        Category(id: "unauth_break", label: "Unauth Break", icon: "hand.raised.slash.fill", color: "c0392b", hasSubType: false, hasDuration: true, hasNotice: false, alwaysNoNotice: true),
        Category(id: "coaching", label: "Coaching", icon: "target", color: "2980b9", hasSubType: false, hasDuration: false, hasNotice: false),
        Category(id: "highlight", label: "Highlight", icon: "star.fill", color: "f39c12", hasSubType: false, hasDuration: false, hasNotice: false),
        Category(id: "note", label: "Note", icon: "note.text", color: "7f8c8d", hasSubType: false, hasDuration: false, hasNotice: false),
    ]
}

// MARK: - Team
struct Team: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var active: Bool
    
    static let defaults: [Team] = [
        Team(id: "t1", name: "Team 1", active: true),
        Team(id: "t2", name: "Team 2", active: false),
        Team(id: "t3", name: "Team 3", active: false),
        Team(id: "t4", name: "Team 4", active: false),
        Team(id: "t5", name: "Team 5", active: false),
    ]
}

// MARK: - Person
struct ImportantDate: Identifiable, Codable, Equatable {
    let id: String
    var label: String
    var date: Date
    var remind: String
    var recurring: Bool
}

struct Person: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var teamId: String
    var dates: [ImportantDate]
    
    init(id: String = UUID().uuidString, name: String, teamId: String, dates: [ImportantDate] = []) {
        self.id = id
        self.name = name
        self.teamId = teamId
        self.dates = dates
    }
}

// MARK: - Entry
struct Followup: Codable, Equatable {
    var hours: Int
    var due: Date
}

struct Entry: Identifiable, Codable, Equatable {
    let id: String
    var personId: String
    var personName: String
    var category: String
    var subType: String?
    var duration: Int?
    var notice: Bool?
    var followup: Followup?
    var notes: String
    var timestamp: Date
    
    init(id: String = UUID().uuidString, personId: String, personName: String, category: String, subType: String? = nil, duration: Int? = nil, notice: Bool? = nil, followup: Followup? = nil, notes: String = "", timestamp: Date = Date()) {
        self.id = id
        self.personId = personId
        self.personName = personName
        self.category = category
        self.subType = subType
        self.duration = duration
        self.notice = notice
        self.followup = followup
        self.notes = notes
        self.timestamp = timestamp
    }
}

// MARK: - Settings
struct FollowupOption: Identifiable, Codable, Equatable {
    var id = UUID()
    var label: String
    var hours: Int
    
    static let defaults: [FollowupOption] = [
        FollowupOption(label: "24 hours", hours: 24),
        FollowupOption(label: "48 hours", hours: 48),
        FollowupOption(label: "72 hours", hours: 72),
        FollowupOption(label: "1 week", hours: 168),
        FollowupOption(label: "2 weeks", hours: 336),
    ]
}

struct DurationSettings: Codable, Equatable {
    var max: Int
    var increment: Int
    
    static let `default` = DurationSettings(max: 60, increment: 5)
}

// MARK: - Reminder
struct Reminder: Identifiable {
    let id = UUID()
    var person: String
    var label: String
    var days: Int
    var isFollowup: Bool
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
