import SwiftUI

struct MapGridView: View {
    let bars: [Bar]
    @Binding var selectedBarUUID: String?
    var onBarTap: (Bar) -> Void = { _ in }
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nearby Bars")
                .font(.headline)
                .padding(.horizontal)
            
            if bars.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "mappin.slash")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No bars nearby")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(bars) { bar in
                        MapCellView(
                            bar: bar,
                            isSelected: selectedBarUUID == bar.uuid
                        ) {
                            selectedBarUUID = bar.uuid
                            onBarTap(bar)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    @State var selectedUUID: String? = nil
    
    let context = PersistenceController.preview.container.viewContext
    var bars: [Bar] = []
    
    for i in 1...4 {
        let bar = Bar(context: context)
        bar.name = "Bar \(i)"
        bar.nameJapanese = "バー\(i)"
        bar.uuid = "bar-\(i)"
        bar.visited = i % 2 == 0
        bars.append(bar)
    }
    
    return MapGridView(bars: bars, selectedBarUUID: $selectedUUID)
        .padding()
}
