import SwiftUI

struct BarListView: View {
    @StateObject var viewModel = BarListViewModel()
    @EnvironmentObject var appState: AppState
    @State private var showSearchView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DynamicBackgroundImage(imageName: appState.barListViewBackground)
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search bars", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    
                    // Statistics
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
                    
                    // Bar List
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
                if viewModel.bars.isEmpty {
                    viewModel.loadBars()
                }
            }
        }
    }
}

struct BarRowView: View {
    let bar: Bar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bar.name ?? "Unknown Bar")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if let japaneseeName = bar.nameJapanese, !japaneseeName.isEmpty {
                        Text(japaneseeName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Visited Status
                if bar.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                }
            }
            
            // Bar Metadata
            HStack(spacing: 12) {
                if let photoURLs = bar.photoURLs as? [String], !photoURLs.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "photo")
                            .font(.caption)
                        Text("\(photoURLs.count)")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                if let tags = bar.tags as? [String], !tags.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "tag")
                            .font(.caption)
                        Text("\(tags.count)")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
                
                Spacer()
                
                // Last Synced
                if let lastSync = bar.lastSyncedDate {
                    Text(lastSync.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    BarListView()
        .environmentObject(AppState())
}
