import SwiftUI

struct BarListView: View {
    @StateObject var viewModel = BarListViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.filteredBars.isEmpty {
                    Text("No bars found")
                        .foregroundColor(.secondary)
                } else {
                    List(viewModel.filteredBars) { bar in
                        NavigationLink(destination: BarDetailView(bar: bar)) {
                            BarRowView(bar: bar)
                        }
                    }
                }
            }
            .navigationTitle("Bars")
            .onAppear {
                viewModel.loadBars()
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .textFieldStyle(.roundedBorder)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}

#Preview {
    BarListView()
        .environmentObject(AppState())
}
