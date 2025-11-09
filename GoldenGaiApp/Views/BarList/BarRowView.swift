import SwiftUI

struct BarRowView: View {
    let bar: Bar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(bar.name ?? "Unknown")
                        .font(.headline)
                    Text(bar.nameJapanese ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if bar.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if let photoURLs = bar.photoURLs as? [String], !photoURLs.isEmpty {
                HStack {
                    Image(systemName: "photo")
                        .font(.caption)
                    Text("\(photoURLs.count) photo\(photoURLs.count > 1 ? "s" : "")")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}


