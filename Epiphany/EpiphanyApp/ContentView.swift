//
//  ContentView.swift
//  Epiphany
//
//  Main tab view container
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sparkles")
                }
                .tag(0)
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "list.bullet")
                }
                .tag(1)
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(2)
            
            ThemesView()
                .tabItem {
                    Label("Themes", systemImage: "paintpalette.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(NotificationManager.shared)
        . modelContainer(DataManager.shared.modelContainer)
}
