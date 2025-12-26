//
//  ThemeModel.swift
//  Epiphany
//

import SwiftUI

struct AppTheme: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let isPremium: Bool
    let backgroundColor: String
    let textColor: String
    let accentColor: String
    
    var backgroundUIColor: Color {
        Color(hex: backgroundColor) ?? .white
    }
    
    var textUIColor: Color {
        Color(hex: textColor) ?? .black
    }
    
    var accentUIColor: Color {
        Color(hex: accentColor) ?? .blue
    }
    
    static let defaultThemes: [AppTheme] = [
        // FREE THEMES (Only 2)
        AppTheme(
            id: "classic",
            name: "Classic",
            isPremium: false,
            backgroundColor: "#FFFFFF",
            textColor: "#000000",
            accentColor: "#007AFF"
        ),
        AppTheme(
            id: "dark",
            name: "Dark",
            isPremium: false,
            backgroundColor: "#000000",
            textColor: "#FFFFFF",
            accentColor: "#0A84FF"
        ),
        
        // PREMIUM THEMES
        AppTheme(
            id: "ocean",
            name: "Ocean",
            isPremium: true,
            backgroundColor: "#1A4D6D",
            textColor: "#E0F4FF",
            accentColor: "#4FA3D1"
        ),
        AppTheme(
            id: "sunset",
            name: "Sunset",
            isPremium: true,
            backgroundColor: "#FF6B6B",
            textColor: "#FFF4E6",
            accentColor: "#FFD93D"
        ),
        AppTheme(
            id: "forest",
            name: "Forest",
            isPremium: true,
            backgroundColor: "#2D5016",
            textColor: "#E8F5E9",
            accentColor: "#7CB342"
        ),
        AppTheme(
            id: "midnight",
            name: "Midnight",
            isPremium: true,
            backgroundColor: "#0A1929",
            textColor: "#B0BEC5",
            accentColor: "#64B5F6"
        ),
        AppTheme(
            id: "lavender",
            name: "Lavender",
            isPremium: true,
            backgroundColor: "#6A5ACD",
            textColor: "#F3E5F5",
            accentColor: "#BA68C8"
        ),
        AppTheme(
            id: "rose",
            name: "Rose",
            isPremium: true,
            backgroundColor: "#C2185B",
            textColor: "#FCE4EC",
            accentColor: "#F06292"
        ),
        AppTheme(
            id: "cream",
            name: "Cream",
            isPremium: true,
            backgroundColor: "#FFF8E1",
            textColor: "#5D4037",
            accentColor: "#FF6F00"
        )
    ]
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
