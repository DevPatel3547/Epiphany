//
//  ContentView.swift
//  Epiphany
//
//  WITH ONBOARDING CHECK
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("selectedThemeID") private var selectedThemeID: String = "dark"
    @State private var showWelcome = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[1]
    }
    
    var body: some View {
        ZStack {
            // Global background color
            currentTheme.backgroundUIColor.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                TodayView()
                    .tabItem {
                        Label("Today", systemImage: "sparkles")
                    }
                    .tag(0)
                
                CategoriesView()
                    .tabItem {
                        Label("Categories", systemImage: "square.grid.2x2")
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
            .accentColor(currentTheme.accentUIColor)
        }
        .preferredColorScheme(selectedThemeID == "dark" ? .dark : .light)
        .onChange(of: selectedThemeID) { oldValue, newValue in
            AppGroup.shared?.set(newValue, forKey: AppGroup.Keys.selectedThemeID)
        }
        .fullScreenCover(isPresented: $showWelcome) {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(NotificationManager.shared)
        .modelContainer(DataManager.shared.modelContainer)
}
