//
//  ThemeModel.swift
//  Epiphany
//
//  Theme system for app and widgets
//

import SwiftUI

struct AppTheme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let isPremium: Bool
    let backgroundColor: String // Hex color
    let textColor: String // Hex color
    let accentColor: String // Hex color
    let fontName: String
    
    var backgroundUIColor: Color {
        Color(hex: backgroundColor)
    }
    
    var textUIColor: Color {
        Color(hex: textColor)
    }
    
    var accentUIColor: Color {
        Color(hex: accentColor)
    }
}

extension AppTheme {
    static let defaultThemes: [AppTheme] = [
        // Free themes
        AppTheme(
            id: "classic",
            name: "Classic",
            isPremium: false,
            backgroundColor: "#FFFFFF",
            textColor: "#000000",
            accentColor: "#007AFF",
            fontName: "System"
        ),
        AppTheme(
            id: "dark",
            name: "Dark",
            isPremium: false,
            backgroundColor: "#1C1C1E",
            textColor: "#FFFFFF",
            accentColor: "#0A84FF",
            fontName: "System"
        ),
        AppTheme(
            id: "minimal",
            name: "Minimal",
            isPremium: false,
            backgroundColor: "#F5F5F7",
            textColor: "#1D1D1F",
            accentColor: "#000000",
            fontName: "System"
        ),
        
        // Premium themes
        AppTheme(
            id: "midnight",
            name: "Midnight",
            isPremium: true,
            backgroundColor: "#0D1117",
            textColor: "#C9D1D9",
            accentColor: "#58A6FF",
            fontName: "Menlo"
        ),
        AppTheme(
            id: "sunset",
            name: "Sunset",
            isPremium: true,
            backgroundColor: "#FF6B6B",
            textColor: "#FFFFFF",
            accentColor: "#FFE66D",
            fontName: "Georgia"
        ),
        AppTheme(
            id: "ocean",
            name: "Ocean",
            isPremium: true,
            backgroundColor: "#006D77",
            textColor: "#EDF6F9",
            accentColor: "#83C5BE",
            fontName: "Helvetica"
        ),
        AppTheme(
            id: "forest",
            name: "Forest",
            isPremium: true,
            backgroundColor: "#2D3142",
            textColor: "#BFC0C0",
            accentColor: "#4F5D75",
            fontName: "Courier"
        ),
        AppTheme(
            id: "cream",
            name: "Cream",
            isPremium: true,
            backgroundColor: "#FFF8E7",
            textColor: "#3C3C3C",
            accentColor: "#D4A373",
            fontName: "Georgia"
        ),
        AppTheme(
            id: "royal",
            name: "Royal",
            isPremium: true,
            backgroundColor: "#4A148C",
            textColor: "#F3E5F5",
            accentColor: "#BA68C8",
            fontName: "Times New Roman"
        )
    ]
}

// Color extension for hex support
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
