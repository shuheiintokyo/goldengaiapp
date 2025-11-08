import Foundation

// MARK: - Language Enum

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

// MARK: - Location Model

struct Location: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func distance(to other: Location) -> Double {
        // Haversine formula for calculating distance between two points
        let earthRadiusKm = 6371.0
        
        let dLat = (other.latitude - latitude).degreesToRadians
        let dLon = (other.longitude - longitude).degreesToRadians
        
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(latitude.degreesToRadians) * cos(other.latitude.degreesToRadians) *
                sin(dLon / 2) * sin(dLon / 2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadiusKm * c
    }
}

// MARK: - Double Extension for Radians

extension Double {
    var degreesToRadians: Double {
        self * .pi / 180.0
    }
    
    var radiansToDegrees: Double {
        self * 180.0 / .pi
    }
}

// MARK: - Sort Options

enum SortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case recentlyVisited = "Recently Visited"
    case distance = "Distance"
    case rating = "Rating"
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(keyPath: \Bar.name, ascending: true)]
        case .nameDescending:
            return [NSSortDescriptor(keyPath: \Bar.name, ascending: false)]
        case .recentlyVisited:
            return [NSSortDescriptor(keyPath: \Bar.visitedDate, ascending: false)]
        case .distance:
            return [NSSortDescriptor(keyPath: \Bar.latitude, ascending: true)]
        case .rating:
            return [] // Would need rating field
        }
    }
}

// MARK: - Filter Options

struct FilterOptions {
    var searchText: String = ""
    var selectedTags: Set<String> = []
    var showVisitedOnly: Bool = false
    var priceRange: ClosedRange<Double>? = nil
    var distanceRange: ClosedRange<Double>? = nil
    
    var isEmpty: Bool {
        searchText.isEmpty &&
        selectedTags.isEmpty &&
        !showVisitedOnly &&
        priceRange == nil &&
        distanceRange == nil
    }
    
    mutating func reset() {
        searchText = ""
        selectedTags.removeAll()
        showVisitedOnly = false
        priceRange = nil
        distanceRange = nil
    }
}

// MARK: - API Response Models

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
}

struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    
    var hasNextPage: Bool {
        (page * pageSize) < total
    }
}

// MARK: - App Version

struct AppVersion: Codable, Equatable {
    let major: Int
    let minor: Int
    let patch: Int
    
    var versionString: String {
        "\(major).\(minor).\(patch)"
    }
    
    static var current: AppVersion {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let components = version.split(separator: ".").map { Int($0) ?? 0 }
        return AppVersion(
            major: components.count > 0 ? components[0] : 1,
            minor: components.count > 1 ? components[1] : 0,
            patch: components.count > 2 ? components[2] : 0
        )
    }
}

// MARK: - Imports needed

import CoreLocation
