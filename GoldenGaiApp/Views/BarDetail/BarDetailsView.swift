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
                // Header with name and visited status
                BarDetailHeader(bar: bar) {
                    try? viewModel.markVisited()
                }
                
                // Bar Information
                if let barInfo = viewModel.barInfo {
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text(barInfo.detailedDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // History Section
                    if let history = barInfo.history {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("History")
                                .font(.headline)
                            
                            Text(history)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            if let priceRange = barInfo.priceRange {
                                DetailRow(label: "Price Range", value: priceRange)
                            }
                            
                            if let hours = barInfo.openingHours {
                                DetailRow(label: "Hours", value: hours)
                            }
                            
                            if let day = barInfo.closingDay {
                                DetailRow(label: "Closed", value: day)
                            }
                            
                            if let capacity = barInfo.capacity {
                                DetailRow(label: "Capacity", value: "\(capacity) people")
                            }
                            
                            if let owner = barInfo.owner {
                                DetailRow(label: "Owner", value: owner)
                            }
                            
                            if let year = barInfo.yearEstablished {
                                DetailRow(label: "Established", value: "\(year)")
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Tags and Features
                    BarTagsSection(bar: bar, barInfo: barInfo)
                    
                    // Photos Section
                    BarPhotoSection(bar: bar) { image in
                        Task {
                            try? await viewModel.uploadPhoto(image)
                        }
                    }
                    
                    // Comments Section
                    BarCommentSection(
                        bar: bar,
                        comments: viewModel.comments
                    ) { content, language in
                        try viewModel.addComment(content, language: language)
                    }
                } else {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Loading bar details...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(bar.name ?? "Bar Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let uuid = bar.uuid {
                viewModel.loadBarDetails(uuid: uuid)
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationView {
        BarDetailView(bar: Bar(entity: NSEntityDescription(), insertInto: nil))
            .environmentObject(AppState())
    }
}
