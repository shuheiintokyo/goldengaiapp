import SwiftUI
import CoreData

// MARK: - Improved MapView with corrected sorting logic
// NOTE: All extensions (Bar, Array, View modifiers, Themes, etc.) are in Models.swift
// This file contains ONLY the MapView and related view components

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
