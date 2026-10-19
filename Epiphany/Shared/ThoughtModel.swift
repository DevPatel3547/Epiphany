//
//  ThoughtModel.swift
//  Epiphany
//
//  UPDATED with 20 categories
//

import Foundation
import SwiftData

@Model
final class Thought {
    @Attribute(.unique) var id: String
    var text: String
    var category: String
    var isFavorite: Bool
    var createdAt: Date
    
    init(id: String, text: String, category: String, isFavorite: Bool = false) {
        self.id = id
        self.text = text
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = Date()
    }
    
    /// Category assigned to thoughts the user captures from the widget, a Control or Shortcuts.
    static let capturedCategory = "Captured"
}

// JSON-decodable version for initial data loading
struct ThoughtData: Codable {
    let id: String
    let text: String
    let category: String
}

// 20 CATEGORIES
enum ThoughtCategory: String, CaseIterable, Codable {
    case philosophy = "Philosophy"
    case science = "Science"
    case technology = "Technology"
    case psychology = "Psychology"
    case language = "Language"
    case society = "Society"
    case existential = "Existential"
    case everyday = "Everyday"
    case time = "Time"
    case mathematics = "Mathematics"
    case nature = "Nature"
    case relationships = "Relationships"
    case consciousness = "Consciousness"
    case history = "History"
    case space = "Space"
    case logic = "Logic"
    case perception = "Perception"
    case identity = "Identity"
    case ethics = "Ethics"
    case reality = "Reality"
    
    var displayName: String {
        self.rawValue
    }
}
