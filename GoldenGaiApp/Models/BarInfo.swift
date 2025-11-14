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

// MARK: - Sort Options

enum SortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case recentlyVisited = "Recently Visited"
    case rating = "Rating"
    
    var sortDescriptors: [NSSortDescriptor] {
        switch self {
        case .nameAscending:
            return [NSSortDescriptor(keyPath: \Bar.name, ascending: true)]
        case .nameDescending:
            return [NSSortDescriptor(keyPath: \Bar.name, ascending: false)]
        case .recentlyVisited:
            return [NSSortDescriptor(keyPath: \Bar.visitedDate, ascending: false)]
        case .rating:
            return []
        }
    }
}

// MARK: - Filter Options

struct FilterOptions {
    var searchText: String = ""
    var selectedTags: Set<String> = []
    var showVisitedOnly: Bool = false
    var priceRange: ClosedRange<Double>? = nil
    
    var isEmpty: Bool {
        searchText.isEmpty &&
        selectedTags.isEmpty &&
        !showVisitedOnly &&
        priceRange == nil
    }
    
    mutating func reset() {
        searchText = ""
        selectedTags.removeAll()
        showVisitedOnly = false
        priceRange = nil
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

// MARK: - Bar Extension for Map Display

extension Bar {
    /// Returns emoji indicator for bar status
    var statusEmoji: String {
        visited ? "🟢" : "🔵"
    }
    
    /// Returns formatted display name for map
    var mapDisplayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return "Unknown"
    }
    
    /// Returns full display with Japanese name
    var fullMapDisplay: String {
        let primaryName = mapDisplayName
        if let japaneseName = nameJapanese, !japaneseName.isEmpty {
            return "\(primaryName)\n(\(japaneseName))"
        }
        return primaryName
    }
    
    /// Calculates distance from another bar (if coordinates were available)
    func distanceFrom(_ bar: Bar) -> Double {
        // TODO: Implement when location data is available
        return 0
    }
}

// MARK: - MapView Statistics Extension

extension Array where Element == Bar {
    var visitedCount: Int {
        filter { $0.visited }.count
    }
    
    var unvisitedCount: Int {
        filter { !$0.visited }.count
    }
    
    var visitedPercentage: Double {
        guard count > 0 else { return 0 }
        return Double(visitedCount) / Double(count) * 100
    }
    
    /// Returns bars grouped by visit status
    var groupedByVisitStatus: (visited: [Bar], unvisited: [Bar]) {
        let visited = filter { $0.visited }
        let unvisited = filter { !$0.visited }
        return (visited, unvisited)
    }
    
    /// Returns most recently visited bars
    func sortedByVisitDate() -> [Bar] {
        sorted { bar1, bar2 in
            let date1 = bar1.visitedDate ?? .distantPast
            let date2 = bar2.visitedDate ?? .distantPast
            return date1 > date2
        }
    }
    
    /// Filters bars by search text
    func search(_ text: String) -> [Bar] {
        guard !text.isEmpty else { return self }
        return filter { bar in
            bar.name?.localizedCaseInsensitiveContains(text) ?? false ||
            bar.nameJapanese?.localizedCaseInsensitiveContains(text) ?? false
        }
    }
}

// MARK: - SwiftUI View Modifiers for Map

struct MapCellModifier: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .background(isSelected ? Color.blue.opacity(0.08) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.blue : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
    }
}

extension View {
    func mapCellStyle(isSelected: Bool) -> some View {
        modifier(MapCellModifier(isSelected: isSelected))
    }
}

// MARK: - Map Color Theme

struct MapTheme {
    static let visitedColor = Color.green
    static let unvisitedColor = Color.blue
    static let visitedBackgroundColor = Color.green.opacity(0.15)
    static let unvisitedBackgroundColor = Color.blue.opacity(0.15)
    static let selectionColor = Color.blue
    static let selectionBackgroundColor = Color.blue.opacity(0.08)
}

// MARK: - MapGridLayout Helper

struct MapGridLayout {
    static let defaultColumnCount = 5
    static let defaultItemSpacing: CGFloat = 8
    static let defaultPadding: CGFloat = 8
    static let defaultCornerRadius: CGFloat = 10
    
    /// Calculates optimal column count based on screen width
    static func optimalColumnCount(for screenWidth: CGFloat) -> Int {
        let itemWidth: CGFloat = 70
        let totalSpacing = defaultPadding * 2 + defaultItemSpacing * CGFloat(defaultColumnCount - 1)
        let availableWidth = screenWidth - totalSpacing
        return max(3, Int(availableWidth / itemWidth))
    }
}

// MARK: - Map Export/Import Helpers

struct MapDataExporter {
    /// Exports map data to JSON format
    static func exportToJSON(_ bars: [Bar]) -> Data? {
        var data: [[String: Any]] = []
        
        for bar in bars {
            var barData: [String: Any] = [
                "uuid": bar.uuid ?? UUID().uuidString,
                "name": bar.name ?? "",
                "nameJapanese": bar.nameJapanese ?? "",
                "visited": bar.visited
            ]
            
            if let visitedDate = bar.visitedDate {
                barData["visitedDate"] = ISO8601DateFormatter().string(from: visitedDate)
            }
            
            if let photoURLs = bar.photoURLs as? [String] {
                barData["photos"] = photoURLs
            }
            
            data.append(barData)
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        } catch {
            print("❌ Export error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Exports map statistics
    static func exportStatistics(_ bars: [Bar]) -> [String: Any] {
        return [
            "totalBars": bars.count,
            "visitedBars": bars.visitedCount,
            "unvisitedBars": bars.unvisitedCount,
            "percentageComplete": bars.visitedPercentage,
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]
    }
}

// MARK: - Map Filtering Presets

struct MapFilterPreset {
    let name: String
    let predicate: (Bar) -> Bool
    
    static let allBars = MapFilterPreset(
        name: "All Bars",
        predicate: { _ in true }
    )
    
    static let visited = MapFilterPreset(
        name: "Visited Only",
        predicate: { $0.visited }
    )
    
    static let unvisited = MapFilterPreset(
        name: "Unvisited Only",
        predicate: { !$0.visited }
    )
    
    static let recent = MapFilterPreset(
        name: "Recently Visited",
        predicate: { $0.visited && $0.visitedDate != nil }
    )
    
    static let allPresets: [MapFilterPreset] = [
        .allBars,
        .visited,
        .unvisited,
        .recent
    ]
}

// MARK: - Map Search Helper

class MapSearchHelper {
    /// Performs fuzzy search on bars
    static func fuzzySearch(_ query: String, in bars: [Bar]) -> [Bar] {
        guard !query.isEmpty else { return bars }
        
        let lowercaseQuery = query.lowercased()
        
        return bars.filter { bar in
            let nameMatch = bar.name?.lowercased().contains(lowercaseQuery) ?? false
            let japaneseMatch = bar.nameJapanese?.contains(query) ?? false
            
            return nameMatch || japaneseMatch
        }.sorted { bar1, bar2 in
            // Prioritize bars that start with the query
            let name1Starts = bar1.name?.lowercased().starts(with: lowercaseQuery) ?? false
            let name2Starts = bar2.name?.lowercased().starts(with: lowercaseQuery) ?? false
            
            if name1Starts && !name2Starts {
                return true
            }
            return false
        }
    }
    
    /// Returns search suggestions based on partial query
    static func suggestions(for query: String, from bars: [Bar]) -> [String] {
        guard !query.isEmpty else { return [] }
        
        let lowercaseQuery = query.lowercased()
        
        return bars.compactMap { bar in
            if let name = bar.name, name.lowercased().starts(with: lowercaseQuery) {
                return name
            }
            return nil
        }
        .removingDuplicates()
        .prefix(5)
        .map { String($0) }
    }
}

// MARK: - Array Extension for Removing Duplicates

extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var result = [Element]()
        for item in self {
            if !result.contains(item) {
                result.append(item)
            }
        }
        return result
    }
}

// MARK: - Map Accessibility

struct MapAccessibilityLabel {
    static func cellLabel(for bar: Bar) -> String {
        let status = bar.visited ? "Visited" : "Unvisited"
        let nameString = bar.name ?? "Unknown bar"
        
        if let japaneseeName = bar.nameJapanese {
            return "\(nameString), \(japaneseeName), \(status)"
        }
        
        return "\(nameString), \(status)"
    }
    
    static func statisticsLabel(visited: Int, total: Int, percentage: Double) -> String {
        let percentString = String(format: "%.0f", percentage)
        return "Progress: \(visited) out of \(total) bars visited, \(percentString) percent complete"
    }
}

// MARK: - Map Animation Helpers

struct MapAnimations {
    static let cellSelection = Animation.easeInOut(duration: 0.2)
    static let panelAppearance = Animation.easeInOut(duration: 0.3)
    static let gridRefresh = Animation.easeInOut(duration: 0.1)
}

// MARK: - Map Haptics

class MapHaptics {
    static func selectionHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func successHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warningHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}

// MARK: - Debug Helper

#if DEBUG
struct MapDebugHelper {
    static func logMapState(bars: [Bar], selectedBar: Bar?, searchText: String) {
        print("""
        ═══════════════════════════════════════
        📊 Map Debug State:
        ───────────────────────────────────────
        Total Bars: \(bars.count)
        Visited: \(bars.visitedCount)
        Unvisited: \(bars.unvisitedCount)
        Completion: \(String(format: "%.1f", bars.visitedPercentage))%
        Selected: \(selectedBar?.name ?? "None")
        Search Text: "\(searchText)"
        ═══════════════════════════════════════
        """)
    }
}
#endif

// MARK: - Map Constants

struct MapConstants {
    static let minCellWidth: CGFloat = 60
    static let maxCellWidth: CGFloat = 100
    static let cellHeight: CGFloat = 100
    
    static let gridSpacing: CGFloat = 8
    static let gridPadding: CGFloat = 8
    
    static let panelHeight: CGFloat = 160
    static let statsPanelHeight: CGFloat = 120
}
