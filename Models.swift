import Foundation
import SwiftUI

// MARK: - Theme
enum AppTheme: String, CaseIterable, Codable {
    case light, dark, rainbow
    
    var displayName: String {
        switch self {
        case .light: return "☀️ Light"
        case .dark: return "🌙 Dark"
        case .rainbow: return "💡 Neon"
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
                bg: Color(hex: "f4f1eb"),
                bgCard: .white,
                bgInput: .white,
                bgNav: .white,
                text: Color(hex: "1a1a2e"),
                textSoft: Color(hex: "666666"),
                textMuted: Color(hex: "aaaaaa"),
                accent: Color(hex: "2d6a4f"),
                accentGlow: Color(hex: "2d6a4f").opacity(0.15),
                border: Color(hex: "e0ddd5"),
                borderAccent: Color(hex: "2d6a4f"),
                danger: Color(hex: "d63031"),
                dangerBg: Color(hex: "fff5f5"),
                warn: Color(hex: "e67e22"),
                warnBg: Color(hex: "fef9ef"),
                gradient: LinearGradient(colors: [Color(hex: "2d6a4f"), Color(hex: "40916c")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .dark:
            return ThemeColors(
                bg: Color(hex: "0a1f1f"),
                bgCard: Color(hex: "001e1e").opacity(0.7),
                bgInput: Color.black.opacity(0.3),
                bgNav: Color(hex: "0a1414").opacity(0.95),
                text: Color(hex: "e0f0ea"),
                textSoft: Color.white.opacity(0.55),
                textMuted: Color.white.opacity(0.25),
                accent: Color(hex: "00e5a0"),
                accentGlow: Color(hex: "00e5a0").opacity(0.15),
                border: Color(hex: "00e5a0").opacity(0.12),
                borderAccent: Color(hex: "00e5a0").opacity(0.4),
                danger: Color(hex: "ff4757"),
                dangerBg: Color(hex: "ff4757").opacity(0.1),
                warn: Color(hex: "f0c040"),
                warnBg: Color(hex: "f0c040").opacity(0.08),
                gradient: LinearGradient(colors: [Color(hex: "00e5a0"), Color(hex: "00b87a")], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
        case .rainbow:
            return ThemeColors(
                bg: Color(hex: "1a1a2e"),
                bgCard: Color(hex: "1e1432").opacity(0.7),
                bgInput: Color.black.opacity(0.3),
                bgNav: Color(hex: "140f28").opacity(0.95),
                text: Color(hex: "f0e6ff"),
                textSoft: Color.white.opacity(0.6),
                textMuted: Color.white.opacity(0.25),
                accent: Color(hex: "e040fb"),
                accentGlow: Color(hex: "e040fb").opacity(0.15),
                border: Color(hex: "e040fb").opacity(0.15),
                borderAccent: Color(hex: "e040fb").opacity(0.4),
                danger: Color(hex: "ff4757"),
                dangerBg: Color(hex: "ff4757").opacity(0.1),
                warn: Color(hex: "ffd93d"),
                warnBg: Color(hex: "ffd93d").opacity(0.08),
                gradient: LinearGradient(colors: [Color(hex: "e040fb"), Color(hex: "536dfe"), Color(hex: "00e5ff")], startPoint: .topLeading, endPoint: .bottomTrailing)
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
        Category(id: "arrival", label: "Arrival", icon: "🚶", color: "2d6a4f", hasSubType: true, subTypes: ["Late", "Early"], hasDuration: true, hasNotice: true),
        Category(id: "lunch", label: "Lunch", icon: "🍔", color: "e67e22", hasSubType: true, subTypes: ["Early", "Late"], hasDuration: true, hasNotice: true),
        Category(id: "early_out", label: "Early Out", icon: "🚪", color: "ff7b54", hasSubType: true, subTypes: ["No Notice", "Short Notice"], hasDuration: true, hasNotice: false),
        Category(id: "no_show", label: "No Show", icon: "👻", color: "d63031", hasSubType: true, subTypes: ["No Notice", "Short Notice"], hasDuration: false, hasNotice: false),
        Category(id: "missing", label: "Missing", icon: "🔍", color: "8e44ad", hasSubType: false, hasDuration: true, hasNotice: true),
        Category(id: "unauth_break", label: "Unauth Break", icon: "🚫", color: "c0392b", hasSubType: false, hasDuration: true, hasNotice: false, alwaysNoNotice: true),
        Category(id: "coaching", label: "Coaching", icon: "🎯", color: "2980b9", hasSubType: false, hasDuration: false, hasNotice: false),
        Category(id: "highlight", label: "Highlight", icon: "⭐", color: "f39c12", hasSubType: false, hasDuration: false, hasNotice: false),
        Category(id: "note", label: "Note", icon: "📝", color: "7f8c8d", hasSubType: false, hasDuration: false, hasNotice: false),
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
