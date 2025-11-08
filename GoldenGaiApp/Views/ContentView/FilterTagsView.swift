import SwiftUI

struct FilterTagsView: View {
    @Binding var selectedTags: Set<String>
    
    let availableTags = [
        "intimate",
        "historic",
        "cozy",
        "friendly",
        "whisky",
        "sake",
        "craft-beer",
        "quiet",
        "lively",
        "casual"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter by Tags")
                .font(.headline)
            
            FlowLayout(items: availableTags) { tag in
                Button(action: {
                    if selectedTags.contains(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                }) {
                    FeatureTag(
                        tag: tag.capitalized,
                        isSelected: selectedTags.contains(tag)
                    )
                }
            }
            
            if !selectedTags.isEmpty {
                Button(role: .destructive) {
                    selectedTags.removeAll()
                } label: {
                    Text("Clear Filters")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    @State var selectedTags: Set<String> = ["intimate", "historic"]
    
    return FilterTagsView(selectedTags: $selectedTags)
        .padding()
}
