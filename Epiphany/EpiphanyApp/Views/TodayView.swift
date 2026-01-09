//
//  TodayView.swift
//  Epiphany
//
//  WITH CATEGORY FILTERING
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allThoughts: [Thought]
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @AppStorage("selectedThemeID") private var selectedThemeID: String = "dark"
    @AppStorage("selectedCategories") private var selectedCategoriesData: Data = Data()
    @State private var showPaywall = false
    
    private var selectedCategories: Set<String> {
        (try? JSONDecoder().decode(Set<String>.self, from: selectedCategoriesData)) ?? []
    }
    
    // Filter thoughts based on selected categories
    private var filteredThoughts: [Thought] {
        if selectedCategories.isEmpty || !subscriptionManager.isPremium {
            return allThoughts
        }
        return allThoughts.filter { selectedCategories.contains($0.category) }
    }
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[1]
    }
    
    var body: some View {
        ZStack {
            currentTheme.backgroundUIColor.ignoresSafeArea()
            
            if filteredThoughts.isEmpty {
                VStack {
                    Text("No thoughts in selected categories")
                        .foregroundColor(currentTheme.textUIColor.opacity(0.5))
                }
            } else {
                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        // Favorites count
                        HStack(spacing: 6) {
                            Image(systemName: "heart")
                                .font(.system(size: 16))
                            Text("\(allThoughts.filter { $0.isFavorite }.count)/\(allThoughts.count)")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(currentTheme.textUIColor.opacity(0.4))
                        
                        Spacer()
                        
                        // Category filter indicator (if premium + categories selected)
                        if subscriptionManager.isPremium && !selectedCategories.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 14))
                                Text("\(selectedCategories.count)")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(currentTheme.accentUIColor)
                        }
                        
                        Spacer()
                        
                        // Premium button
                        Button {
                            showPaywall = true
                        } label: {
                            Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "crown")
                                .font(.system(size: 16))
                                .foregroundColor(subscriptionManager.isPremium ? .yellow : currentTheme.textUIColor.opacity(0.4))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Scrollable cards
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredThoughts, id: \.id) { thought in
                                ThoughtCardView(
                                    thought: thought,
                                    theme: currentTheme,
                                    onToggleFavorite: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            DataManager.shared.toggleFavorite(thought)
                                        }
                                    }
                                )
                                .containerRelativeFrame(.vertical)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0.8)
                                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// ThoughtCardView stays the same
struct ThoughtCardView: View {
    let thought: Thought
    let theme: AppTheme
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text(thought.category)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.accentUIColor.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(theme.accentUIColor.opacity(0.1)))
                .padding(.bottom, 24)
            
            Text(thought.text)
                .font(.system(size: 26, weight: .regular, design: .rounded))
                .foregroundColor(theme.textUIColor)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 40)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            HStack(spacing: 50) {
                ShareLink(item: thought.text) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                        Text("Share")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(theme.textUIColor.opacity(0.5))
                }
                
                Button {
                    onToggleFavorite()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: thought.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 22))
                        Text("Like")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(thought.isFavorite ? .red : theme.textUIColor.opacity(0.5))
                }
                .buttonStyle(.plain)
                .highPriorityGesture(TapGesture().onEnded {
                    onToggleFavorite()
                })
                
                Button {
                    UIPasteboard.general.string = thought.text
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 22))
                        Text("Copy")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(theme.textUIColor.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(theme.backgroundUIColor.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    TodayView()
        .environmentObject(SubscriptionManager.shared)
        .modelContainer(DataManager.shared.modelContainer)
}
