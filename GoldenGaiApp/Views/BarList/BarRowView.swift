import SwiftUI

struct BarRowView: View {
    let bar: Bar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Name Row
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(bar.name ?? "Unknown")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if let japaneseName = bar.nameJapanese, !japaneseName.isEmpty {
                        Text(japaneseName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Visited indicator
                if bar.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            // Photos info (if any)
            if let photoURLs = bar.photoURLs as? [String], !photoURLs.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "photo.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("\(photoURLs.count) photo\(photoURLs.count > 1 ? "s" : "")")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}
