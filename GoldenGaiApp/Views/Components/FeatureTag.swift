import SwiftUI

struct FeatureTag: View {
    let tag: String
    var isSelected: Bool = false
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

#Preview {
    HStack {
        FeatureTag(tag: "Intimate", isSelected: true)
        FeatureTag(tag: "Historic")
    }
    .padding()
}
