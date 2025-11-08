import Foundation

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
    let features: [String]
    let comments: [BarComment]
    
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
        case features
        case comments
    }
}

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
