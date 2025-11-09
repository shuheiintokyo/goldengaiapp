import SwiftUI

struct BarDetailHeader: View {
    let bar: Bar
    let onMarkVisited: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(bar.name ?? "Unknown Bar")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(bar.nameJapanese ?? "")
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
