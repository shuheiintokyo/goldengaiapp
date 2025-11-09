import SwiftUI

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var appState: AppState
    @State private var selectedBar: Bar?
    @State private var showBarDetail = false
    
    let columns = [
        GridItem(.adaptive(minimum: 70), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                DynamicBackgroundImage(imageName: appState.mapViewBackground)
                
                VStack(spacing: 0) {
                    // Title & Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Golden Gai Map")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                Text("Unvisited")
                                    .font(.caption)
                            }
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Visited")
                                    .font(.caption)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    
                    // Bar Grid
                    if viewModel.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading map...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else if viewModel.visibleBars.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "map")
                                .font(.title)
                                .foregroundColor(.gray)
                            Text("No bars available")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 8) {
                                ForEach(viewModel.visibleBars) { bar in
                                    NavigationLink(
                                        destination: BarDetailView(bar: bar)
                                    ) {
                                        MapCellView(
                                            bar: bar,
                                            isSelected: viewModel.selectedBar?.uuid == bar.uuid,
                                            onTap: {
                                                viewModel.selectBar(bar)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Selected Bar Info
                    if let selectedBar = viewModel.selectedBar {
                        VStack(alignment: .leading, spacing: 8) {
                            Divider()
                            
                            Text(selectedBar.name ?? "Unknown")
                                .font(.headline)
                            
                            if let japaneseeName = selectedBar.nameJapanese {
                                Text(japaneseeName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                if selectedBar.visited {
                                    Label("Visited", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                } else {
                                    Label("Not visited", systemImage: "circle")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                NavigationLink(destination: BarDetailView(bar: selectedBar)) {
                                    Text("Details")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                    }
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if viewModel.bars.isEmpty {
                    viewModel.loadBars()
                }
            }
        }
    }
}

struct MapCellView: View {
    let bar: Bar
    let isSelected: Bool
    var onTap: () -> Void = {}
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bar.visited ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                    
                    VStack(spacing: 2) {
                        Circle()
                            .fill(bar.visited ? Color.green : Color.blue)
                            .frame(width: 12, height: 12)
                        
                        Image(systemName: "mappin.circle")
                            .font(.title3)
                            .foregroundColor(bar.visited ? .green : .blue)
                    }
                }
                .frame(height: 50)
                
                Text(bar.name ?? "?")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding(4)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
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

#Preview {
    MapView()
        .environmentObject(AppState())
}
