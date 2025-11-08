import SwiftUI

struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content
    var spacing: CGFloat = 8
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            var row: [String] = []
            
            ForEach(0..<items.count, id: \.self) { index in
                if index > 0 && row.count > 0 {
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.self) { item in
                            content(item)
                        }
                        Spacer()
                    }
                }
                row.append(items[index])
            }
            
            if !row.isEmpty {
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                    Spacer()
                }
            }
        }
    }
}
