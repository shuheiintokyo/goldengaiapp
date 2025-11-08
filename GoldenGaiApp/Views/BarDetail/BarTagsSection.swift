import SwiftUI

struct BarTagsSection: View {
    let bar: Bar
    let barInfo: BarInfo?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features & Tags")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                if !bar.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(items: bar.tags) { tag in
                            FeatureTag(tag: tag)
                        }
                    }
                }
                
                if let barInfo = barInfo, !barInfo.features.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Features")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(items: barInfo.features) { feature in
                            FeatureTag(tag: feature, isSelected: true)
                        }
                    }
                }
                
                if let barInfo = barInfo, !barInfo.specialties.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specialties")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(items: barInfo.specialties) { specialty in
                            FeatureTag(tag: specialty)
                        }
                    }
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
    bar.tags = ["intimate", "historic", "cozy"]
    
    let barInfo = BarInfo(
        id: "bar-001",
        features: ["Vintage", "Quiet"],
        specialties: ["Sake", "Whisky"]
    )
    
    return BarTagsSection(bar: bar, barInfo: barInfo)
        .padding()
}
