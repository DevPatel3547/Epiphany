//
//  DataManager.swift
//  Epiphany
//
//  Manages SwiftData persistence and thought loading.
//  The store lives in the App Group container, so the app and the widget
//  extension (including its App Intents) read and write the same database.
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
class DataManager {
    static let shared = DataManager()
    
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    private init() {
        let schema = Schema([Thought.self])
        
        // Get App Group URL or fall back to default
        let storeURL: URL
        if let containerURL = AppGroup.containerURL {
            storeURL = containerURL.appendingPathComponent("thoughts.sqlite")
        } else {
            // Fallback to documents directory if App Group not available
            storeURL = URL.documentsDirectory.appendingPathComponent("thoughts.sqlite")
        }
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            url: storeURL,
            cloudKitDatabase: .none
        )
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // Load initial thoughts if database is empty
        Task {
            await loadInitialThoughtsIfNeeded()
        }
    }
    
    func loadInitialThoughtsIfNeeded() async {
        let descriptor = FetchDescriptor<Thought>()
        
        do {
            let existingCount = try modelContext.fetchCount(descriptor)
            if existingCount == 0 {
                await loadThoughtsFromJSON()
            }
        } catch {
            print("Error checking thought count: \(error)")
        }
    }
    
    func loadThoughtsFromJSON() async {
        guard let url = Bundle.main.url(forResource: "thoughts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let thoughtsData = try? JSONDecoder().decode([ThoughtData].self, from: data) else {
            print("Could not load thoughts.json")
            return
        }
        
        for thoughtData in thoughtsData {
            let thought = Thought(
                id: thoughtData.id,
                text: thoughtData.text,
                category: thoughtData.category
            )
            modelContext.insert(thought)
        }
        
        do {
            try modelContext.save()
            print("Loaded \(thoughtsData.count) thoughts from JSON")
        } catch {
            print("Error saving thoughts: \(error)")
        }
    }
    
    func fetchAllThoughts() -> [Thought] {
        let descriptor = FetchDescriptor<Thought>(sortBy: [SortDescriptor(\.createdAt)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchFavorites() -> [Thought] {
        var descriptor = FetchDescriptor<Thought>(
            predicate: #Predicate { $0.isFavorite == true }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt)]
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchThoughts(category: String?) -> [Thought] {
        if let category = category {
            var descriptor = FetchDescriptor<Thought>(
                predicate: #Predicate { $0.category == category }
            )
            descriptor.sortBy = [SortDescriptor(\.createdAt)]
            return (try? modelContext.fetch(descriptor)) ?? []
        } else {
            return fetchAllThoughts()
        }
    }
    
    func toggleFavorite(_ thought: Thought) {
        thought.isFavorite.toggle()
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Capture (used by widget buttons, Controls and Shortcuts)
    
    /// The thought currently surfaced on the widget, persisted in the App Group.
    var currentWidgetThought: Thought? {
        guard let id = AppGroup.shared?.string(forKey: AppGroup.Keys.lastThoughtID) else { return nil }
        return getThought(by: id)
    }
    
    func setCurrentWidgetThought(_ thought: Thought) {
        AppGroup.shared?.set(thought.id, forKey: AppGroup.Keys.lastThoughtID)
    }
    
    /// Toggles a thought's favorite state by ID. Returns the new state, or nil if not found.
    @discardableResult
    func toggleFavorite(id: String) -> Bool? {
        guard let thought = getThought(by: id) else { return nil }
        thought.isFavorite.toggle()
        try? modelContext.save()
        return thought.isFavorite
    }
    
    /// Saves a new user-written thought straight into the shared store.
    @discardableResult
    func captureThought(text: String) -> Thought? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let thought = Thought(
            id: "captured-\(UUID().uuidString)",
            text: trimmed,
            category: Thought.capturedCategory,
            isFavorite: true
        )
        modelContext.insert(thought)
        do {
            try modelContext.save()
        } catch {
            print("Error saving captured thought: \(error)")
            return nil
        }
        return thought
    }
    
    func getRandomThought() -> Thought? {
        let thoughts = fetchAllThoughts()
        return thoughts.randomElement()
    }
    
    func getThought(by id: String) -> Thought? {
        var descriptor = FetchDescriptor<Thought>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }
}
