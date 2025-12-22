//
//  FavoritesView.swift
//  Epiphany
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Thought> { $0.isFavorite == true }) private var favorites: [Thought]
    
    @State private var selectedThemeID: String = "classic"
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[0]
    }
    
    var body: some View {
        NavigationStack {
            if favorites.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No favorites yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text("Tap the heart icon on thoughts you love")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                List {
                    ForEach(favorites) { thought in
                        ThoughtRow(thought: thought, theme: currentTheme)
                    }
                }
                .navigationTitle("Favorites")
            }
        }
        .onAppear {
            if let themeID = AppGroup.shared?.string(forKey: AppGroup.Keys.selectedThemeID) {
                selectedThemeID = themeID
            }
        }
    }
}
