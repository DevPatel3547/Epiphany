//
//  DataManager.swift
//  Epiphany
//
//  Manages SwiftData persistence and thought loading
//

import Foundation
import SwiftData

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
