//
//  BrowseView.swift
//  Epiphany
//

import SwiftUI
import SwiftData

struct BrowseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allThoughts: [Thought]
    
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""
    @State private var selectedThemeID: String = "classic"
    
    private var filteredThoughts: [Thought] {
        var results = allThoughts
        
        if let category = selectedCategory {
            results = results.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            results = results.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
        
        return results
    }
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[0]
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(ThoughtCategory.allCases, id: \.self) { category in
                                FilterChip(
                                    title: category.displayName,
                                    isSelected: selectedCategory == category.rawValue
                                ) {
                                    selectedCategory = category.rawValue
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                
                ForEach(filteredThoughts) { thought in
                    ThoughtRow(thought: thought, theme: currentTheme)
                }
            }
            .navigationTitle("Browse")
            .searchable(text: $searchText, prompt: "Search thoughts")
            .onAppear {
                if let themeID = AppGroup.shared?.string(forKey: AppGroup.Keys.selectedThemeID) {
                    selectedThemeID = themeID
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ThoughtRow: View {
    let thought: Thought
    let theme: AppTheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(thought.text)
                .font(.body)
            
            HStack {
                Text(thought.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if thought.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            DataManager.shared.toggleFavorite(thought)
        }
    }
}
