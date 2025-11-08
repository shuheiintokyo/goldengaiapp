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
            
            if bar.visited, let date = bar.visitedDate {
                HStack {
                    Image(systemName: "checkmark")
                        .font(.caption)
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                }
                .foregroundColor(.green)
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
    bar.visited = true
    bar.visitedDate = Date()
    
    return BarDetailHeader(bar: bar, onMarkVisited: {})
        .padding()
}
