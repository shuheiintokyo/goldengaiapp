import SwiftUI

struct BarDetailHeader: View {
    let bar: Bar
    let onMarkVisited: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bar.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(bar.displayNameJapanese)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onMarkVisited) {
                    Image(systemName: bar.visited ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(bar.visited ? .green : .gray)
                }
            }
            
            HStack(spacing: 12) {
                Label("📍 \(String(format: "%.4f", bar.latitude))", systemImage: "location.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if bar.visited, let date = bar.visitedDate {
                    Label("Visited", systemImage: "checkmark")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let bar = Bar(context: context)
    bar.name = "Test Bar"
    bar.nameJapanese = "テストバー"
    bar.latitude = 35.6656
    bar.longitude = 139.7360
    bar.visited = true
    bar.visitedDate = Date()
    
    return BarDetailHeader(bar: bar, onMarkVisited: {})
        .padding()
}
