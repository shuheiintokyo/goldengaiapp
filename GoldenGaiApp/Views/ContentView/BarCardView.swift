import SwiftUI

struct BarCardView: View {
    let bar: Bar
    var onTap: () -> Void = {}
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bar.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(bar.displayNameJapanese)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if bar.visited {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                }
                
                HStack(spacing: 16) {
                    if bar.hasPhotos {
                        Label("\(bar.photoCount)", systemImage: "photo")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let bar = Bar(context: context)
    bar.name = "Test Bar"
    bar.nameJapanese = "テストバー"
    bar.visited = true
    bar.photoURLs = ["photo1.jpg", "photo2.jpg"]
    
    return BarCardView(bar: bar)
        .padding()
}
