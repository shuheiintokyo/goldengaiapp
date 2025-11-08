import Foundation

// MARK: - BarInfo Model

struct BarInfo: Codable, Identifiable {
    let id: String // Same as Bar.uuid
    let detailedDescription: String
    let history: String?
    let specialties: [String]
    let priceRange: String?
    let openingHours: String?
    let closingDay: String?
    let capacity: Int?
    let owner: String?
    let year established: Int?
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
        case yearEstablished = "year_established"
        case features
        case comments
    }
    
    init(
        id: String,
        detailedDescription: String = "",
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
        self.year = yearEstablished
        self.features = features
        self.comments = comments
    }
}

// MARK: - BarComment Model

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

// MARK: - Language Enum

enum Language: String, Codable, CaseIterable {
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
}

// MARK: - Mock Data for Preview

#if DEBUG
extension BarInfo {
    static var preview: BarInfo {
        BarInfo(
            id: "bar-001",
            detailedDescription: "A cozy izakaya in the heart of Golden Gai with intimate seating for 5-6 people.",
            history: "Established in 1985, this bar has been serving locals and visitors for nearly 40 years.",
            specialties: ["Sake", "Whisky", "Traditional Japanese Snacks"],
            priceRange: "¥1,000 - ¥3,000",
            openingHours: "6:00 PM - 12:00 AM",
            closingDay: "Sunday",
            capacity: 6,
            owner: "Tanaka San",
            yearEstablished: 1985,
            features: ["Intimate", "Historic", "Cash Only"],
            comments: [
                BarComment(
                    id: "comment-001",
                    barUUID: "bar-001",
                    author: "Traveler",
                    content: "Amazing atmosphere! The owner is very friendly.",
                    language: .english,
                    rating: 5.0,
                    createdAt: Date(),
                    updatedAt: nil
                )
            ]
        )
    }
}
#endif
