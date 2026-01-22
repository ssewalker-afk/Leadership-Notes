//
//  Theme.swift
//  CoachingLog
//
//  Created on 1/20/26.
//

import SwiftUI

struct AppTheme {
    // MARK: - Background Colors
    static let backgroundPrimary = Color(hex: "0b1220")
    static let backgroundSecondary = Color(hex: "111827")
    static let backgroundTertiary = Color(hex: "11182B")
    
    // MARK: - Text Colors
    static let textPrimary = Color(hex: "f8fafc")
    static let textSecondary = Color(hex: "cbd5e1")
    static let textMuted = Color(hex: "94a3b8")
    
    // MARK: - Accent Colors
    static let accentPurple = Color(hex: "7C3AED")
    static let accentPurpleDark = Color(hex: "5B21B6")
    static let accentPink = Color(hex: "EC4899")
    static let accentCyan = Color(hex: "22D3EE")
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [accentPurple, accentPurpleDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentPurple, accentPink],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Typography
    static func interFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Color Extension for Hex Support
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
