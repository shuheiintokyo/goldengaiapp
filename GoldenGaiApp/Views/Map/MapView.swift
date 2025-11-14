import SwiftUI
import CoreData

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
            return "\(primaryName)\n(japaneseName)"
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
