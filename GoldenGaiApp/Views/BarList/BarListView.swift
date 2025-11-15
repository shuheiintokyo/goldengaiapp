import Foundation
import SwiftUI
import CoreData

struct BarListView: View {
    @StateObject var viewModel = BarListViewModel()
    @EnvironmentObject var appState: AppState
    @State private var didLoad = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DynamicBackgroundImage(imageName: appState.barListViewBackground)
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText)
                        .padding(.vertical, 8)
                    
                    // Statistics Card
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Visited")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Text("\(viewModel.visitedCount)")
                                    .font(.headline)
                                Text("/ \(viewModel.totalCount)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ProgressView(value: viewModel.visitedPercentage / 100)
                                .frame(width: 100)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    
                    // Bar List Content
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading bars...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else if viewModel.filteredBars.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("No bars found")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else {
                        List(viewModel.filteredBars) { bar in
                            NavigationLink(destination: BarDetailView(bar: bar)) {
                                BarRowView(bar: bar)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Golden Gai Bars")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
            }
            .onAppear {
                print("📋 BarListView appeared")
                if !didLoad {
                    didLoad = true
                    print("🔄 Loading bars from repository...")
                    viewModel.loadBars()
                } else {
                    print("✅ Bars already loaded, count: \(viewModel.bars.count)")
                }
            }
            .onChange(of: viewModel.selectedSortOption) { _ in
                print("🔀 Sort option changed to: \(viewModel.selectedSortOption.rawValue)")
                viewModel.updateFilteredBars()
            }
            .onChange(of: viewModel.showVisitedOnly) { newValue in
                print("🔍 Visited filter toggled: \(newValue)")
                viewModel.updateFilteredBars()
            }
            .onChange(of: viewModel.searchText) { newValue in
                print("🔎 Search text changed: \(newValue)")
                viewModel.updateFilteredBars()
            }
        }
    }
}
