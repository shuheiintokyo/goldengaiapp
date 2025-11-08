import SwiftUI

struct BarRowView: View {
    let bar: Bar
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(bar.displayName)
                        .font(.headline)
                    Text(bar.displayNameJapanese)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if bar.visited {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if bar.hasPhotos {
                HStack {
                    Image(systemName: "photo")
                        .font(.caption)
                    Text("\(bar.photoCount) photo\(bar.photoCount > 1 ? "s" : "")")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let bar = Bar(context: context)
    bar.name = "Test Bar"
    bar.nameJapanese = "テストバー"
    bar.visited = true
    bar.photoURLs = ["photo1.jpg"]
    
    return BarRowView(bar: bar)
}
