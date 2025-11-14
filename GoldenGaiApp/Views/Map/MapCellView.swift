import SwiftUI
import CoreData

struct MapCellView: View {
    let row: Int
    let column: Int
    let cellSize: CGFloat
    let bars: FetchedResults<Bar>
    let highlightedBarUUID: String?
    let showEnglish: Bool
    let onBarSelected: (Bar) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var refreshTrigger = UUID()
    
    // Helper function to check if a bar is a vacant placeholder
    private func isVacantPlaceholder(_ bar: Bar) -> Bool {
        guard let name = bar.name else { return false }
        return name == "*" || name == "_VACANT_" || name == "---"
    }
    
    // Calculate dynamic font size based on cell size and text length
    private func dynamicFontSize(for text: String, spanWidth: Int, spanHeight: Int) -> CGFloat {
        guard spanWidth > 0, spanHeight > 0, cellSize > 0 else {
            return 10
        }
        
        let textLength = max(text.count, 1)
        let availableWidth = max(cellSize * CGFloat(spanWidth) - 4, 1)
        let availableHeight = max(cellSize * CGFloat(spanHeight) - 4, 1)
        
        var fontSize = min(availableWidth / CGFloat(textLength) * 2.0, availableHeight * 0.3)
        fontSize = max(fontSize, 6)
        fontSize = min(fontSize, cellSize * 0.25)
        
        return fontSize
    }
    
    var body: some View {
        // Validate cell size early
        guard cellSize > 0 else {
            return AnyView(Color.clear.frame(width: 1, height: 1))
        }
        
        let bar = findBar(at: row, column: column)
        let occupyingBar = bar == nil ? findBarOccupyingThisCell(row: row, column: column) : nil
        let isVacant = bar != nil && isVacantPlaceholder(bar!)
        let activeBar = bar ?? occupyingBar
        
        guard let activeBar = activeBar else {
            // Truly empty cell
            return AnyView(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: cellSize, height: cellSize)
            )
        }
        
        let hSpan = max(Int(activeBar.cellSpanHorizontal ?? 1), 1)
        let vSpan = max(Int(activeBar.cellSpanVertical ?? 1), 1)
        let bgColor = cellBackgroundColor(for: activeBar, isVacant: isVacant)
        
        // Check if this is the start cell of the bar
        let isStartCell = (bar != nil)
        
        return AnyView(
            ZStack {
                Color.clear
                    .frame(width: cellSize, height: cellSize)
                
                // Only render on the start cell
                if isStartCell {
                    let displayText = activeBar.name ?? ""
                    
                    ZStack {
                        Rectangle()
                            .fill(bgColor)
                            .overlay(
                                Rectangle()
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        // Text rendering
                        if !isVacant && !displayText.isEmpty {
                            Text(displayText)
                                .font(.system(size: dynamicFontSize(
                                    for: displayText,
                                    spanWidth: hSpan,
                                    spanHeight: vSpan
                                )))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .minimumScaleFactor(0.4)
                                .padding(2)
                        }
                    }
                    .frame(
                        width: max(cellSize * CGFloat(hSpan), 1),
                        height: max(cellSize * CGFloat(vSpan), 1)
                    )
                    .offset(
                        x: cellSize * CGFloat(hSpan - 1) / 2,
                        y: cellSize * CGFloat(vSpan - 1) / 2
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isVacant {
                            onBarSelected(activeBar)
                        }
                    }
                    .onLongPressGesture(minimumDuration: 0.5) {
                        if !isVacant {
                            activeBar.visited = !activeBar.visited
                            try? viewContext.save()
                            
                            // Post notification for UI refresh
                            NotificationCenter.default.post(
                                name: NSNotification.Name("BarStatusUpdated"),
                                object: nil,
                                userInfo: ["barUUID": activeBar.uuid ?? ""]
                            )
                        }
                    }
                    .id(refreshTrigger)
                } else {
                    // Non-start cells are COMPLETELY TRANSPARENT
                    Color.clear
                        .frame(width: cellSize, height: cellSize)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isVacant {
                                onBarSelected(activeBar)
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            if !isVacant {
                                activeBar.visited = !activeBar.visited
                                try? viewContext.save()
                                
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("BarStatusUpdated"),
                                    object: nil,
                                    userInfo: ["barUUID": activeBar.uuid ?? ""]
                                )
                            }
                        }
                        .id(refreshTrigger)
                }
            }
            .frame(width: cellSize, height: cellSize)
            // Listen for bar status updates and refresh immediately
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BarStatusUpdated"))) { notification in
                if let uuid = notification.userInfo?["barUUID"] as? String,
                   uuid == activeBar.uuid {
                    print("🔄 MapCellView: Received BarStatusUpdated for \(activeBar.name ?? "unknown") at (\(row), \(column))")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            refreshTrigger = UUID()
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Helper Functions
    
    private func cellBackgroundColor(for bar: Bar?, isVacant: Bool) -> Color {
        guard let bar = bar else {
            return Color.white.opacity(0.1)
        }
        
        if isVacant {
            return Color.gray.opacity(0.15)
        }
        
        // First check visited status
        if bar.visited {
            return Color.green.opacity(0.6)
        }
        
        // Check for highlight
        if let highlightUUID = highlightedBarUUID,
           !highlightUUID.isEmpty,
           highlightUUID != "nil",
           let barUUID = bar.uuid,
           !barUUID.isEmpty,
           barUUID != "nil",
           highlightUUID == barUUID {
            print("🎯 Highlighting bar: \(bar.name ?? "unknown") with UUID: \(barUUID)")
            return Color.blue.opacity(0.7)
        }
        
        // Default color for non-visited, non-highlighted bars
        return Color.white.opacity(0.9)
    }
    
    private func findBar(at row: Int, column: Int) -> Bar? {
        bars.first { Int($0.locationRow) == row && Int($0.locationColumn) == column }
    }
    
    private func findBarOccupyingThisCell(row: Int, column: Int) -> Bar? {
        bars.first { bar in
            let startRow = Int(bar.locationRow)
            let startCol = Int(bar.locationColumn)
            let hSpan = Int(bar.cellSpanHorizontal)
            let vSpan = Int(bar.cellSpanVertical)
            
            let isInRowRange = row >= startRow && row < (startRow + vSpan)
            let isInColRange = column >= startCol && column < (startCol + hSpan)
            
            return isInRowRange && isInColRange && !(row == startRow && column == startCol)
        }
    }
}
