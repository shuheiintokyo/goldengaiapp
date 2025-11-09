import SwiftUI
import Foundation
import CoreData
import Combine

struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content
    var spacing: CGFloat = 8
    
    var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: 80), spacing: spacing)
        ]
        
        LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
            ForEach(items, id: \.self){item in
                content(item)
            }
        }
    }
}
