import Foundation
import CoreData
import Combine
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
    private let imageService: ImageService
    
    @MainActor
    init(
        barRepository: BarRepository? = nil,
        barInfoService: BarInfoService? = nil,
        imageService: ImageService? = nil
    ) {
        self.barRepository = barRepository ?? CoreDataBarRepository.shared
        self.barInfoService = barInfoService ?? BarInfoService()
        self.imageService = imageService ?? ImageService()
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
                bar.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                bar.nameJapanese?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Tag filter
        if !selectedTags.isEmpty {
            filtered = filtered.filter { bar in
                if let tags = bar.tags as? [String]{
                    let barTags = Set(tags)
                    return !selectedTags.intersection(barTags).isEmpty
                }
                return false
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
