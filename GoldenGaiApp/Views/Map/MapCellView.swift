import SwiftUI
import CoreLocation

struct MapCellView: View {
    let bar: Bar
    let isSelected: Bool
    var onTap: () -> Void = {}
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(bar.visited ? Color.green : Color.blue)
                    
                    Image(systemName: "mappin")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(width: 40, height: 40)
                
                Text(bar.name ?? "Unknown")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                if isSelected {
                    Text(bar.nameJapanese ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: isSelected ? 4 : 2)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.blue : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

