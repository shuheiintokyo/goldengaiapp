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

// NOTE: SortOption is defined in Models.swift - do not duplicate here!

// MARK: - Improved MapView with corrected sorting logic

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedBar: Bar?
    @State private var showBarDetail = false
    @State private var selectedSortOption: SortOption = .nameAscending
    @State private var showFilters = false
    
    let columns = [
        GridItem(.adaptive(minimum: 70), spacing: 8)
    ]
    
    var filteredBars: [Bar] {
        var filtered = viewModel.visibleBars
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { bar in
                bar.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                bar.nameJapanese?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Sort - Fixed to work without KVO
        filtered = sortBars(filtered)
        
        return filtered
    }
    
    /// Sorts bars using proper Swift sorting instead of KVO
    private func sortBars(_ bars: [Bar]) -> [Bar] {
        switch selectedSortOption {
        case .nameAscending:
            return bars.sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDescending:
            return bars.sorted { ($0.name ?? "") > ($1.name ?? "") }
        case .recentlyVisited:
            return bars.sorted { a, b in
                let dateA = a.visitedDate ?? .distantPast
                let dateB = b.visitedDate ?? .distantPast
                return dateA > dateB
            }
        case .rating:
            // Rating sorting - implement when rating data is available
            return bars
        }
    }
    
    var visitedCount: Int {
        viewModel.visibleBars.filter { $0.visited }.count
    }
    
    var totalCount: Int {
        viewModel.visibleBars.count
    }
    
    var visitedPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(visitedCount) / Double(totalCount) * 100
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DynamicBackgroundImage(imageName: appState.mapViewBackground)
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.vertical, 8)
                    
                    // Map Info & Stats
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Golden Gai Map")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("\(filteredBars.count) bars")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Legend
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                    Text("Unvisited")
                                        .font(.caption2)
                                }
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                    Text("Visited")
                                        .font(.caption2)
                                }
                            }
                        }
                        
                        // Progress Card
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 4) {
                                    Text("\(visitedCount)")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    Text("/ \(totalCount)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            ProgressView(value: visitedPercentage / 100)
                                .frame(maxWidth: .infinity)
                            
                            Text(String(format: "%.0f%%", visitedPercentage))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .frame(width: 35)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    
                    // Bar Grid
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading Golden Gai...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else if filteredBars.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("No bars found")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(filteredBars) { bar in
                                    NavigationLink(destination: BarDetailView(bar: bar)) {
                                        MapBarCell(
                                            bar: bar,
                                            isSelected: viewModel.selectedBar?.uuid == bar.uuid,
                                            onTap: {
                                                viewModel.selectBar(bar)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // Selected Bar Info Panel
                    if let selectedBar = viewModel.selectedBar {
                        SelectedBarPanel(bar: selectedBar)
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $selectedSortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            .onAppear {
                if viewModel.bars.isEmpty {
                    viewModel.loadBars()
                }
            }
        }
    }
}

// MARK: - Map Bar Cell Component

struct MapBarCell: View {
    let bar: Bar
    let isSelected: Bool
    var onTap: () -> Void = {}
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                // Pin Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(bar.visited ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    
                    VStack(spacing: 2) {
                        // Status Indicator
                        Circle()
                            .fill(bar.visited ? Color.green : Color.blue)
                            .frame(width: 10, height: 10)
                        
                        // Pin Icon
                        Image(systemName: "mappin.circle.fill")
                            .font(.title3)
                            .foregroundColor(bar.visited ? .green : .blue)
                    }
                }
                .frame(height: 56)
                
                // Bar Name
                VStack(spacing: 2) {
                    Text(bar.name ?? "?")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    if let japaneseeName = bar.nameJapanese, !japaneseeName.isEmpty {
                        Text(japaneseeName)
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(4)
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
}

// MARK: - Selected Bar Panel

struct SelectedBarPanel: View {
    let bar: Bar
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bar.name ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let japaneseeName = bar.nameJapanese {
                        Text(japaneseeName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if bar.visited {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.green)
                        
                        Text("Visited")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                } else {
                    VStack(spacing: 2) {
                        Image(systemName: "circle")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("Unvisited")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                NavigationLink(destination: BarDetailView(bar: bar)) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                        Text("Details")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                
                Button(action: { }) {
                    HStack(spacing: 4) {
                        Image(systemName: bar.visited ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption)
                        Text(bar.visited ? "Visited" : "Mark")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(bar.visited ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(bar.visited ? .green : .primary)
                    .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

// MARK: - Preview

#Preview {
    MapView()
        .environmentObject(AppState())
}
