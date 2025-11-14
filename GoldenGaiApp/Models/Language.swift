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

