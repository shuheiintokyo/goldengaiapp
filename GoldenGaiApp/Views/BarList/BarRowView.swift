import SwiftUI

struct BarRowView: View {
    let bar: Bar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bar.name ?? "Unknown")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Text(bar.nameJapanese ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if bar.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            if let photoURLs = bar.photoURLs as? [String], !photoURLs.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "photo")
                        .font(.caption2)
                    Text("\(photoURLs.count) photo\(photoURLs.count > 1 ? "s" : "")")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}
