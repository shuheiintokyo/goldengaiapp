import Foundation
import SwiftUI
import CoreData

struct BarListView: View {
    @StateObject var viewModel = BarListViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @State private var didLoad = false
    
    var body: some View {
        ZStack {
            // Background
            DynamicBackgroundImage(imageName: appState.barListViewBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // HEADER
                HStack(spacing: 12) {
                    Text("Golden Gai Bars")
                        .font(.title3)
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
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground).opacity(0.95))
                
                // SEARCH BAR
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.caption)
                    
                    TextField("Search bars...", text: $viewModel.searchText)
                        .font(.body)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(6)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground).opacity(0.95))
                
                // STATS
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Visited")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.visitedCount)/\(viewModel.totalCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    ProgressView(value: viewModel.visitedPercentage / 100)
                        .frame(height: 4)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6).opacity(0.9))
                
                // CONTENT
                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading bars...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredBars.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("No bars found")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 6) {
                            ForEach(viewModel.filteredBars, id: \.uuid) { bar in
                                NavigationLink(destination: BarDetailView(bar: bar)) {
                                    BarListItemView(bar: bar)
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .background(Color.clear)
                }
                
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            print("📋 BarListView appeared")
            if !didLoad {
                didLoad = true
                print("🔄 Loading bars from repository...")
                viewModel.loadBars()
                print("📊 Total bars loaded: \(viewModel.bars.count)")
                print("📍 Filtered bars: \(viewModel.filteredBars.count)")
            }
        }
        .onChange(of: viewModel.selectedSortOption) { _ in
            viewModel.updateFilteredBars()
        }
        .onChange(of: viewModel.showVisitedOnly) { _ in
            viewModel.updateFilteredBars()
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.updateFilteredBars()
        }
    }
}

// MARK: - Bar List Item View
struct BarListItemView: View {
    let bar: Bar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Name Row
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(bar.name ?? "Unknown Bar")
                        .font(.body)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if let japaneseName = bar.nameJapanese, !japaneseName.isEmpty {
                        Text(japaneseName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Visited indicator
                if bar.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.body)
                }
            }
            
            // Photos info
            if let photoURLs = bar.photoURLs as? [String], !photoURLs.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "photo.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(photoURLs.count) photo\(photoURLs.count > 1 ? "s" : "")")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}

#Preview {
    BarListView()
        .environmentObject(AppState())
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
