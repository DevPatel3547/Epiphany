//
//  EpiphanyApp.swift
//  Epiphany
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct EpiphanyApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionManager)
                .environmentObject(notificationManager)
                .modelContainer(DataManager.shared.modelContainer)
        }
    }
}
