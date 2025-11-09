import SwiftUI

struct BarTagsSection: View {
    let bar: Bar
    let barInfo: BarInfo?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features & Tags")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                if let tags = bar.tags as? [String], !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        FlowLayout(items: tags) { tag in
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


