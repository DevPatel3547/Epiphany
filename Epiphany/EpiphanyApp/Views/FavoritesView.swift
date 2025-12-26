//
//  FavoritesView.swift
//  Epiphany
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Thought> { $0.isFavorite == true }) private var favorites: [Thought]
    
    @AppStorage("selectedThemeID") private var selectedThemeID: String = "dark"
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[1]
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
    }
}

#Preview {
    FavoritesView()
        .modelContainer(DataManager.shared.modelContainer)
}
