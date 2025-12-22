//
//  ThoughtModel.swift
//  Epiphany
//
//  Shared model for shower thoughts
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
}

// JSON-decodable version for initial data loading
struct ThoughtData: Codable {
    let id: String
    let text: String
    let category: String
}

// Categories
enum ThoughtCategory: String, CaseIterable, Codable {
    case existential = "Existential"
    case science = "Science"
    case language = "Language"
    case society = "Society"
    case philosophy = "Philosophy"
    case everyday = "Everyday"
    case technology = "Technology"
    case nature = "Nature"
    
    var displayName: String {
        self.rawValue
    }
}
