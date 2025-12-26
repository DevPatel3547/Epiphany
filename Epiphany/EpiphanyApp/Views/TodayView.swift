//
//  TodayView.swift
//  Epiphany
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var thoughts: [Thought]
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @AppStorage("selectedThemeID") private var selectedThemeID: String = "dark"
    @State private var showPaywall = false
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[1]
    }
    
    var body: some View {
        ZStack {
            // Background color from theme
            currentTheme.backgroundUIColor.ignoresSafeArea()
            
            if thoughts.isEmpty {
                // Empty state
                VStack {
                    Text("No thoughts yet")
                        .foregroundColor(currentTheme.textUIColor.opacity(0.5))
                }
            } else {
                VStack(spacing: 0) {
                    // Top bar with icons (blends into background, no navbar)
                    HStack {
                        // Favorites count indicator
                        HStack(spacing: 6) {
                            Image(systemName: "heart")
                                .font(.system(size: 16))
                            Text("\(thoughts.filter { $0.isFavorite }.count)/\(thoughts.count)")
                                .font(.system(size: 14))
                        }
                        .foregroundColor(currentTheme.textUIColor.opacity(0.4))
                        
                        Spacer()
                        
                        // Premium button - navigates to same PaywallView as Settings
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
                    
                    // Scrollable card feed - VERTICAL ONLY, NO HORIZONTAL SWIPE
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(thoughts, id: \.id) { thought in
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

// MARK: - Thought Card Component
struct ThoughtCardView: View {
    let thought: Thought
    let theme: AppTheme
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Category badge at top
            Text(thought.category)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(theme.accentUIColor.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(theme.accentUIColor.opacity(0.1))
                )
                .padding(.bottom, 24)
            
            // Main thought text - large, centered
            Text(thought.text)
                .font(.system(size: 26, weight: .regular, design: .rounded))
                .foregroundColor(theme.textUIColor)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 40)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            // Action buttons INSIDE each card
            HStack(spacing: 50) {
                // Share button
                ShareLink(item: thought.text) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                        Text("Share")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(theme.textUIColor.opacity(0.5))
                }
                
                // Like button - empty when not liked, filled when liked
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
                
                // Copy button
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
