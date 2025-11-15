import Foundation
import SwiftUI
import CoreData
import Combine

// MARK: - BarListViewModel

@MainActor
class BarListViewModel: ObservableObject {
    @Published var bars: [Bar] = []
    @Published var filteredBars: [Bar] = []
    @Published var searchText: String = ""
    @Published var showVisitedOnly: Bool = false
    @Published var selectedSortOption: SortOption = .nameAscending
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let barRepository: BarRepository
    
    init(barRepository: BarRepository = CoreDataBarRepository.shared) {
        self.barRepository = barRepository
        updateFilteredBars()
    }
    
    // MARK: - Load Data
    
    func loadBars() {
        isLoading = true
        errorMessage = nil
        
        do {
            bars = barRepository.fetch()
            updateFilteredBars()
            print("✅ Loaded \(bars.count) bars")
        } catch {
            errorMessage = "Failed to load bars: \(error.localizedDescription)"
            print("❌ Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Filtering & Sorting
    
    func updateFilteredBars() {
        var filtered = bars
        
        // Apply visit filter
        if showVisitedOnly {
            filtered = filtered.filter { $0.visited }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { bar in
                bar.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                bar.nameJapanese?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Apply sort
        filtered = sortBars(filtered)
        
        filteredBars = filtered
    }
    
    /// Sorts bars using proper Swift sorting instead of KVO
    private func sortBars(_ barsToSort: [Bar]) -> [Bar] {
        switch selectedSortOption {
        case .nameAscending:
            return barsToSort.sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDescending:
            return barsToSort.sorted { ($0.name ?? "") > ($1.name ?? "") }
        case .recentlyVisited:
            return barsToSort.sorted { a, b in
                let dateA = a.visitedDate ?? .distantPast
                let dateB = b.visitedDate ?? .distantPast
                return dateA > dateB
            }
        case .rating:
            // Rating sorting - implement when rating data is available
            return barsToSort
        }
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
