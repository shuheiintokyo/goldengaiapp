import SwiftUI

struct BarDetailView: View {
    let bar: Bar
    @StateObject var viewModel: BarDetailViewModel
    @EnvironmentObject var appState: AppState
    
    init(bar: Bar) {
        self.bar = bar
        _viewModel = StateObject(wrappedValue: BarDetailViewModel(bar: bar))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(bar.name ?? "Unknown")
                            .font(.title)
                        Text(bar.nameJapanese ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        try? viewModel.markVisited()
                    }) {
                        Image(systemName: bar.visited ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(bar.visited ? .green : .gray)
                    }
                }
                .padding()
                
                if let barInfo = viewModel.barInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(barInfo.detailedDescription)
                            .font(.body)
                        
                        if let history = barInfo.history {
                            Text(history)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
        .navigationTitle("Bar Details")
        .onAppear {
            if let uuid = bar.uuid {
                viewModel.loadBarDetails(uuid: uuid)
            }
        }
    }
}

