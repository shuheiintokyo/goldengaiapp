import Foundation
import SwiftUI
import CoreData

struct BarListView: View {
    @StateObject var viewModel = BarListViewModel()
    @EnvironmentObject var appState: AppState
    @State private var didLoad = false
    
    var body: some View {
        ZStack {
            // Background - Behind everything
            DynamicBackgroundImage(imageName: appState.barListViewBackground)
                .ignoresSafeArea()
            
            // Content - Constrained within safe area
            VStack(spacing: 0) {
                // Header Section - Fixed height
                VStack(spacing: 0) {
                    // Navigation Title + Menu
                    HStack {
                        Text("Golden Gai Bars")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Menu {
                            Picker("Sort", selection: $viewModel.selectedSortOption) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            
                            Divider()
                            
                            Toggle("Visited Only", isOn: $viewModel.showVisitedOnly)
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground).opacity(0.9))
                    
                    // Search Bar - Properly constrained
                    SearchBar(text: $viewModel.searchText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(.systemBackground).opacity(0.9))
                    
                    // Statistics Card - Properly constrained
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Visited")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            HStack(spacing: 2) {
                                Text("\(viewModel.visitedCount)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("/ \(viewModel.totalCount)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Progress")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            ProgressView(value: viewModel.visitedPercentage / 100)
                                .frame(maxWidth: 80)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6).opacity(0.9))
                }
                
                // Bar List Content - Scrollable, properly constrained
                ZStack {
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading bars...")
                                .foregroundColor(.secondary)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else if viewModel.filteredBars.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("No bars found")
                                .foregroundColor(.secondary)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(spacing: 4) {
                                ForEach(viewModel.filteredBars) { bar in
                                    NavigationLink(destination: BarDetailView(bar: bar)) {
                                        BarRowView(bar: bar)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                        .background(Color.clear)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            print("📋 BarListView appeared")
            if !didLoad {
                didLoad = true
                print("🔄 Loading bars from repository...")
                viewModel.loadBars()
                print("📊 Total bars loaded: \(viewModel.bars.count)")
                print("📍 Filtered bars: \(viewModel.filteredBars.count)")
            } else {
                print("✅ Bars already loaded, count: \(viewModel.bars.count)")
            }
        }
        .onChange(of: viewModel.selectedSortOption) { _ in
            print("🔀 Sort option changed to: \(viewModel.selectedSortOption.rawValue)")
            print("   Filtered count: \(viewModel.filteredBars.count)")
            viewModel.updateFilteredBars()
        }
        .onChange(of: viewModel.showVisitedOnly) { newValue in
            print("🔍 Visited filter toggled: \(newValue)")
            print("   Filtered count: \(viewModel.filteredBars.count)")
            viewModel.updateFilteredBars()
        }
        .onChange(of: viewModel.searchText) { newValue in
            print("🔎 Search text changed: '\(newValue)'")
            print("   Filtered count: \(viewModel.filteredBars.count)")
            viewModel.updateFilteredBars()
        }
    }
}
