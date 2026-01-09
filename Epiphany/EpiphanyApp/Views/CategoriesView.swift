//
//  CategoriesView.swift
//  Epiphany
//
//  Category selection for 20 categories
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @AppStorage("selectedThemeID") private var selectedThemeID: String = "dark"
    @AppStorage("selectedCategories") private var selectedCategoriesData: Data = Data()
    @State private var showPaywall = false
    
    private var selectedCategories: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: selectedCategoriesData)) ?? []
        }
    }
    
    private func toggleCategory(_ category: String) {
        var current = selectedCategories
        if current.contains(category) {
            current.remove(category)
        } else {
            current.insert(category)
        }
        if let encoded = try? JSONEncoder().encode(current) {
            selectedCategoriesData = encoded
        }
    }
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[1]
    }
    
    var body: some View {
        NavigationStack {
            if subscriptionManager.isPremium {
                // PREMIUM: Category selection
                VStack(spacing: 20) {
                    // Instructions
                    Text("Select categories you want to see")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    // Category grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(ThoughtCategory.allCases, id: \.self) { category in
                                CategoryCard(
                                    category: category,
                                    isSelected: selectedCategories.contains(category.rawValue),
                                    theme: currentTheme
                                ) {
                                    toggleCategory(category.rawValue)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Info text
                    if selectedCategories.isEmpty {
                        Text("No categories selected - showing all thoughts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom)
                    } else {
                        Text("\(selectedCategories.count) categories selected")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.bottom)
                    }
                }
                .navigationTitle("Categories")
            } else {
                // FREE: Locked
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Select Your Categories")
                        .font(.title2.bold())
                    
                    Text("Upgrade to Premium to choose which categories you want to see on your Today feed.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Unlock Premium")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .navigationTitle("Categories")
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct CategoryCard: View {
    let category: ThoughtCategory
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: categoryIcon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : theme.accentUIColor)
                
                // Name
                Text(category.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? theme.accentUIColor : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(theme.accentUIColor, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var categoryIcon: String {
        switch category {
        case .philosophy: return "brain.head.profile"
        case .science: return "atom"
        case .technology: return "laptopcomputer"
        case .psychology: return "person.fill.questionmark"
        case .language: return "textformat"
        case .society: return "person.3.fill"
        case .existential: return "questionmark.circle"
        case .everyday: return "house.fill"
        case .time: return "clock.fill"
        case .mathematics: return "function"
        case .nature: return "leaf.fill"
        case .relationships: return "heart.circle.fill"
        case .consciousness: return "eye.fill"
        case .history: return "book.closed.fill"
        case .space: return "sparkles"
        case .logic: return "puzzlepiece.fill"
        case .perception: return "eye.trianglebadge.exclamationmark.fill"
        case .identity: return "person.crop.circle.fill"
        case .ethics: return "scale.3d"
        case .reality: return "cube.transparent.fill"
        }
    }
}

#Preview {
    CategoriesView()
        .environmentObject(SubscriptionManager.shared)
}
