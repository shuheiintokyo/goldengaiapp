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
        case features
        case comments
    }
    
    // MARK: - Preview for SwiftUI
    
    #if DEBUG
    static var preview: BarInfo {
        BarInfo(
            id: "bar-001",
            detailedDescription: "A cozy and intimate bar in the heart of Golden Gai",
            history: "Established in 1985, this historic bar has been a favorite among locals",
            specialties: ["Japanese Whisky", "Sake"],
            priceRange: "¥1,000 - ¥3,000",
            openingHours: "6:00 PM - 12:00 AM",
            closingDay: "Monday",
            capacity: 5,
            owner: "Yamada-san",
            features: ["Intimate", "Historic", "Friendly Owner"],
            comments: [
                BarComment(
                    id: "c1",
                    barUUID: "bar-001",
                    author: "Traveler",
                    content: "Great atmosphere!",
                    language: .english,
                    rating: 5.0,
                    createdAt: Date(),
                    updatedAt: nil
                )
            ]
        )
    }
    #endif
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
