//
//  ThemesView.swift
//  Epiphany
//

import SwiftUI

struct ThemesView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @AppStorage("selectedThemeID") private var selectedThemeID: String = "dark"
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Free themes
                    SectionHeader(title: "Free Themes")
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(AppTheme.defaultThemes.filter { !$0.isPremium }) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: selectedThemeID == theme.id,
                                isPremium: false
                            ) {
                                selectTheme(theme)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Premium themes
                    SectionHeader(title: "Premium Themes")
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(AppTheme.defaultThemes.filter { $0.isPremium }) { theme in
                            ThemeCard(
                                theme: theme,
                                isSelected: selectedThemeID == theme.id,
                                isPremium: !subscriptionManager.isPremium
                            ) {
                                if subscriptionManager.isPremium {
                                    selectTheme(theme)
                                } else {
                                    showPaywall = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Themes")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
    
    private func selectTheme(_ theme: AppTheme) {
        selectedThemeID = theme.id
        AppGroup.shared?.set(theme.id, forKey: AppGroup.Keys.selectedThemeID)
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundUIColor)
                    .frame(height: 120)
                    .overlay(
                        VStack {
                            Text("Aa")
                                .font(.largeTitle)
                                .foregroundColor(theme.textUIColor)
                            Text("Preview")
                                .font(.caption)
                                .foregroundColor(theme.accentUIColor)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
                
                HStack {
                    Text(theme.name)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    if isPremium {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

#Preview {
    ThemesView()
        .environmentObject(SubscriptionManager.shared)
}
