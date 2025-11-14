import Foundation
import SwiftUI
import CoreData

struct BarSearchView: View {
    @StateObject var viewModel = BarListViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText)
                    .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Show Visited Only", isOn: $viewModel.showVisitedOnly)
                    
                    Picker("Sort By", selection: $viewModel.selectedSortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                if viewModel.filteredBars.isEmpty {
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
            .navigationTitle("Search Bars")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadBars()
            }
        }
    }
}

#Preview {
    BarSearchView()
}
