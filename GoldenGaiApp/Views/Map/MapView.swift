import SwiftUI

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text("Map View")
                    .font(.headline)
                    .padding()
                
                List(viewModel.visibleBars) { bar in
                    Text(bar.displayName)
                }
            }
        }
        .navigationTitle("Map")
        .onAppear {
            viewModel.loadBars()
        }
    }
}

#Preview {
    MapView()
        .environmentObject(AppState())
}
