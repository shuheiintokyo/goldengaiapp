import Foundation
import CoreData
import SwiftUI

// MARK: - Language Enum (MISSING - ADD THIS!)

enum Language: String, Codable, CaseIterable, Hashable {
    case japanese = "ja"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .japanese:
            return "日本語"
        case .english:
            return "English"
        }
    }
    
    var code: String {
        self.rawValue
    }
    
    var locale: Locale {
        Locale(identifier: self.rawValue)
    }
}

// MARK: - BarComment (INCOMPLETE - FIX THIS!)

struct BarComment: Codable, Identifiable {
    let id: String
    let barUUID: String
    let author: String
    let content: String
    let language: Language
    let rating: Double?
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case barUUID = "bar_uuid"
        case author
        case content
        case language
        case rating
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - BarInfo

struct BarInfo: Codable, Identifiable {
    let id: String
    let detailedDescription: String
    let history: String?
    let specialties: [String]
    let priceRange: String?
    let openingHours: String?
    let closingDay: String?
    let capacity: Int?
    let owner: String?
    let yearEstablished: Int?
    let features: [String]
    var comments: [BarComment]
    
    enum CodingKeys: String, CodingKey {
        case id
        case detailedDescription = "description"
        case history
        case specialties
        case priceRange
        case openingHours
        case closingDay
        case capacity
        case owner
        case yearEstablished = "year_established"
        case features
        case comments
    }
    
    init(
        id: String,
        detailedDescription: String,
        history: String? = nil,
        specialties: [String] = [],
        priceRange: String? = nil,
        openingHours: String? = nil,
        closingDay: String? = nil,
        capacity: Int? = nil,
        owner: String? = nil,
        yearEstablished: Int? = nil,
        features: [String] = [],
        comments: [BarComment] = []
    ) {
        self.id = id
        self.detailedDescription = detailedDescription
        self.history = history
        self.specialties = specialties
        self.priceRange = priceRange
        self.openingHours = openingHours
        self.closingDay = closingDay
        self.capacity = capacity
        self.owner = owner
        self.yearEstablished = yearEstablished
        self.features = features
        self.comments = comments
    }
}

// MARK: - Tag Model

struct Tag: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let nameJapanese: String
    let category: TagCategory
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case nameJapanese = "name_japanese"
        case category
    }
}

enum TagCategory: String, Codable, CaseIterable {
    case bar = "bar"
    case atmosphere = "atmosphere"
    case price = "price"
    case specialty = "specialty"
    case feature = "feature"
    
    var displayName: String {
        switch self {
        case .bar:
            return "Bar Type"
        case .atmosphere:
            return "Atmosphere"
        case .price:
            return "Price Range"
        case .specialty:
            return "Specialty"
        case .feature:
            return "Features"
        }
    }
}
