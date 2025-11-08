import Foundation
import SwiftUI

@MainActor
class BarListViewModel: ObservableObject {
    @Published var bars: [Bar] = []
    @Published var filteredBars: [Bar] = []
    @Published var searchText: String = "" {
        didSet {
            filterBars()
        }
    }
    @Published var selectedSortOption: SortOption = .nameAscending {
        didSet {
            sortBars()
        }
    }
    @Published var selectedTags: Set<String> = [] {
        didSet {
            filterBars()
        }
    }
    @Published var showVisitedOnly: Bool = false {
        didSet {
            filterBars()
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let barRepository: BarRepository
    private let barInfoService: BarInfoService
    
    init(
        barRepository: BarRepository = CoreDataBarRepository.shared,
        barInfoService: BarInfoService = BarInfoService()
    ) {
        self.barRepository = barRepository
        self.barInfoService = barInfoService
    }
    
    // MARK: - Loading
    
    func loadBars() {
        isLoading = true
        errorMessage = nil
        
        do {
            bars = barRepository.fetch()
            filterBars()
            print("✅ Loaded \(bars.count) bars")
        } catch {
            errorMessage = "Failed to load bars"
            print("❌ Error loading bars: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filtering
    
    func filterBars() {
        var filtered = bars
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { bar in
                bar.displayName.localizedCaseInsensitiveContains(searchText) ||
                bar.displayNameJapanese.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Tag filter
        if !selectedTags.isEmpty {
            filtered = filtered.filter { bar in
                let barTags = Set(bar.tags)
                return !selectedTags.intersection(barTags).isEmpty
            }
        }
        
        // Visited filter
        if showVisitedOnly {
            filtered = filtered.filter { $0.visited }
        }
        
        filteredBars = filtered
        sortBars()
    }
    
    // MARK: - Sorting
    
    func sortBars() {
        let descriptors = selectedSortOption.sortDescriptors
        filteredBars.sort { bar1, bar2 in
            for descriptor in descriptors {
                let key1 = bar1.value(forKey: descriptor.key as! String) ?? ""
                let key2 = bar2.value(forKey: descriptor.key as! String) ?? ""
                
                if let key1 = key1 as? String, let key2 = key2 as? String {
                    let result = key1.localizedCaseInsensitiveCompare(key2)
                    if result != .orderedSame {
                        return descriptor.ascending ? result == .orderedAscending : result == .orderedDescending
                    }
                }
            }
            return false
        }
    }
    
    // MARK: - Bar Actions
    
    func toggleVisited(_ bar: Bar) throws {
        bar.visited = !bar.visited
        bar.visitedDate = bar.visited ? Date() : nil
        try barRepository.update(bar)
        filterBars()
    }
    
    func deleteBar(_ bar: Bar) throws {
        try barRepository.delete(bar)
        bars.removeAll { $0.uuid == bar.uuid }
        filterBars()
    }
    
    func getBarInfo(_ bar: Bar) -> BarInfo? {
        guard let uuid = bar.uuid else { return nil }
        return barInfoService.getBarInfo(for: uuid)
    }
    
    // MARK: - Statistics
    
    var visitedCount: Int {
        bars.filter { $0.visited }.count
    }
    
    var totalCount: Int {
        bars.count
    }
    
    var visitedPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(visitedCount) / Double(totalCount) * 100
    }
}

// MARK: - Preview Support

#if DEBUG
extension BarListViewModel {
    static var preview: BarListViewModel {
        let vm = BarListViewModel()
        vm.bars = [
            mockBar1,
            mockBar2,
            mockBar3
        ]
        vm.filteredBars = vm.bars
        return vm
    }
}

// Mock Bars for preview
let mockBar1: Bar = {
    let bar = Bar(context: PersistenceController.preview.container.viewContext)
    bar.uuid = "bar-001"
    bar.name = "The Bar"
    bar.nameJapanese = "ザ・バー"
    bar.latitude = 35.6656
    bar.longitude = 139.7360
    bar.visited = true
    bar.visitedDate = Date()
    bar.tags = ["intimate", "historic"]
    bar.photoURLs = ["photo1.jpg"]
    return bar
}()

let mockBar2: Bar = {
    let bar = Bar(context: PersistenceController.preview.container.viewContext)
    bar.uuid = "bar-002"
    bar.name = "Another Bar"
    bar.nameJapanese = "別のバー"
    bar.latitude = 35.6660
    bar.longitude = 139.7365
    bar.visited = false
    bar.tags = ["cozy"]
    bar.photoURLs = []
    return bar
}()

let mockBar3: Bar = {
    let bar = Bar(context: PersistenceController.preview.container.viewContext)
    bar.uuid = "bar-003"
    bar.name = "Special Spot"
    bar.nameJapanese = "特別な場所"
    bar.latitude = 35.6665
    bar.longitude = 139.7370
    bar.visited = true
    bar.visitedDate = Date(timeIntervalSinceNow: -86400)
    bar.tags = ["whisky", "friendly"]
    bar.photoURLs = ["photo2.jpg", "photo3.jpg"]
    return bar
}()
#endif
