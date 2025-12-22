//
//  TodayView.swift
//  Epiphany
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var thoughts: [Thought]
    
    @State private var currentIndex = 0
    @State private var selectedThemeID: String = "classic"
    
    private var currentThought: Thought? {
        guard !thoughts.isEmpty else { return nil }
        return thoughts[currentIndex]
    }
    
    private var currentTheme: AppTheme {
        AppTheme.defaultThemes.first { $0.id == selectedThemeID } ?? AppTheme.defaultThemes[0]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                currentTheme.backgroundUIColor.ignoresSafeArea()
                
                if let thought = currentThought {
                    VStack(spacing: 24) {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Text(thought.text)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(currentTheme.textUIColor)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Text(thought.category)
                                .font(.caption)
                                .foregroundColor(currentTheme.accentUIColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(currentTheme.accentUIColor.opacity(0.2)))
                        }
                        .padding(32)
                        .background(RoundedRectangle(cornerRadius: 20).fill(currentTheme.backgroundUIColor).shadow(radius: 10))
                        .padding(.horizontal)
                        .gesture(
                            DragGesture().onEnded { value in
                                if value.translation.width < -50 { nextThought() }
                                else if value.translation.width > 50 { previousThought() }
                            }
                        )
                        
                        HStack(spacing: 24) {
                            Button { DataManager.shared.toggleFavorite(thought) } label: {
                                Image(systemName: thought.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2).foregroundColor(currentTheme.accentUIColor)
                            }
                            Button { UIPasteboard.general.string = thought.text } label: {
                                Image(systemName: "doc.on.doc")
                                    .font(.title2).foregroundColor(currentTheme.accentUIColor)
                            }
                            ShareLink(item: thought.text) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2).foregroundColor(currentTheme.accentUIColor)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Today")
            .onAppear {
                if let themeID = AppGroup.shared?.string(forKey: AppGroup.Keys.selectedThemeID) {
                    selectedThemeID = themeID
                }
                if !thoughts.isEmpty { currentIndex = Int.random(in: 0..<thoughts.count) }
            }
        }
    }
    
    private func nextThought() {
        guard !thoughts.isEmpty else { return }
        currentIndex = (currentIndex + 1) % thoughts.count
    }
    
    private func previousThought() {
        guard !thoughts.isEmpty else { return }
        currentIndex = (currentIndex - 1 + thoughts.count) % thoughts.count
    }
}
