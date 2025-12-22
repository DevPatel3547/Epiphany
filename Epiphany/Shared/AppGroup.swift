//
//  AppGroup.swift
//  Epiphany
//
//  App Group configuration for sharing data with widgets
//

import Foundation

enum AppGroup {
    static let identifier = "group.com.epiphany.app"
    
    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
    
    // Shared UserDefaults for simple settings
    static var shared: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}

// Keys for UserDefaults
extension AppGroup {
    enum Keys {
        static let selectedThemeID = "selectedThemeID"
        static let isPremium = "isPremium"
        static let notificationsEnabled = "notificationsEnabled"
        static let notificationTimes = "notificationTimes"
        static let lastThoughtID = "lastThoughtID"
    }
}
