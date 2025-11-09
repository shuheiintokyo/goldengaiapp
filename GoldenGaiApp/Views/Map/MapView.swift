import SwiftUI

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Map View")
                        .font(.headline)
                        .padding()
                    
                    if viewModel.visibleBars.isEmpty {
                        Text("No bars available")
                            .foregroundColor(.secondary)
                    } else {
                        List(viewModel.visibleBars) { bar in
                            Text(bar.name ?? "Unknown Bar")
                        }
                    }
                }
            }
            .navigationTitle("Map")
            .onAppear {
                viewModel.loadBars()
            }
        }
    }
}

#Preview {
    MapView()
        .environmentObject(AppState())
}
