import SwiftUI
import CoreData

// MARK: - MapGridView (Fixed)

struct MapGridView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bar.locationRow, ascending: true)],
        animation: .default)
    private var bars: FetchedResults<Bar>
    
    let highlightedBarUUID: String?
    let showEnglish: Bool
    let onBarSelected: (Bar) -> Void
    let onHighlightChange: (String?) -> Void
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    @AppStorage("showEnglish") private var showEnglishSetting = false
    
    // Grid dimensions from map.json
    private let rows = 35
    private let columns = 21
    
    // Parameters
    private let horizontalPadding: CGFloat = 4
    private let topPadding: CGFloat = 8
    private let tabBarHeight: CGFloat = 10
    private let bottomPadding: CGFloat = 20
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate available space
            let availableWidth = geometry.size.width - (horizontalPadding * 2)
            let availableHeight = geometry.size.height - topPadding - tabBarHeight - bottomPadding
            
            // Calculate cell size to fit perfectly
            let cellSizeByWidth = availableWidth / CGFloat(columns)
            let cellSizeByHeight = availableHeight / CGFloat(rows)
            let calculatedCellSize = min(cellSizeByWidth, cellSizeByHeight)
            
            // Calculate the actual grid dimensions
            let initialGridWidth = calculatedCellSize * CGFloat(columns)
            let initialGridHeight = calculatedCellSize * CGFloat(rows)
            
            // Calculate max offset bounds based on zoom
            let maxOffsetX = max((initialGridWidth * currentScale - initialGridWidth) / 2, 0)
            let maxOffsetY = max((initialGridHeight * currentScale - initialGridHeight) / 2, 0)
            
            VStack(spacing: 0) {
                // Top spacer
                Spacer()
                    .frame(height: topPadding)
                
                // Main grid area with reset button overlay
                ZStack(alignment: .bottomTrailing) {
                    // Grid container
                    VStack(spacing: 0) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<columns, id: \.self) { column in
                                    MapCellView(
                                        row: row,
                                        column: column,
                                        cellSize: calculatedCellSize,
                                        bars: bars,
                                        highlightedBarUUID: highlightedBarUUID,
                                        showEnglish: showEnglishSetting,
                                        onBarSelected: onBarSelected
                                    )
                                    .id("\(row)-\(column)")
                                }
                            }
                        }
                    }
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .scaleEffect(currentScale, anchor: .center)
                    .offset(x: offset.width, y: offset.height)
                    .gesture(
                        // Drag gesture for panning
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard currentScale > 1.0 else { return }
                                isDragging = true
                                
                                let newOffsetX = lastOffset.width + value.translation.width
                                let newOffsetY = lastOffset.height + value.translation.height
                                
                                offset.width = min(max(newOffsetX, -maxOffsetX), maxOffsetX)
                                offset.height = min(max(newOffsetY, -maxOffsetY), maxOffsetY)
                            }
                            .onEnded { value in
                                isDragging = false
                                
                                guard currentScale > 1.0 else {
                                    offset = .zero
                                    lastOffset = .zero
                                    return
                                }
                                
                                let newOffsetX = lastOffset.width + value.translation.width
                                let newOffsetY = lastOffset.height + value.translation.height
                                
                                offset.width = min(max(newOffsetX, -maxOffsetX), maxOffsetX)
                                offset.height = min(max(newOffsetY, -maxOffsetY), maxOffsetY)
                                lastOffset = offset
                            }
                            .simultaneously(with:
                                // Pinch-to-zoom gesture
                                MagnificationGesture()
                                    .onChanged { value in
                                        let newScale = lastScale * value
                                        let clampedScale = min(max(newScale, 1.0), 3.0)
                                        currentScale = clampedScale
                                        
                                        // Recalculate bounds during zoom
                                        let currentMaxOffsetX = max((initialGridWidth * currentScale - initialGridWidth) / 2, 0)
                                        let currentMaxOffsetY = max((initialGridHeight * currentScale - initialGridHeight) / 2, 0)
                                        
                                        // Constrain offset to new bounds
                                        offset.width = min(max(offset.width, -currentMaxOffsetX), currentMaxOffsetX)
                                        offset.height = min(max(offset.height, -currentMaxOffsetY), currentMaxOffsetY)
                                    }
                                    .onEnded { value in
                                        let newScale = lastScale * value
                                        currentScale = min(max(newScale, 1.0), 3.0)
                                        lastScale = currentScale
                                        
                                        // Reset offset when zooming back to 1.0
                                        if currentScale <= 1.0 {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                offset = .zero
                                                lastOffset = .zero
                                            }
                                        } else {
                                            // Save constrained offset
                                            lastOffset = offset
                                        }
                                    }
                            )
                    )
                    
                    // Reset button - only shows when zoomed
                    if currentScale > 1.0 {
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                currentScale = 1.0
                                lastScale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Reset")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.bottom, 16)
                        .padding(.trailing, 16)
                        .transition(.opacity)
                    }
                }
                
                // Bottom spacer with proper padding from tab bar
                Spacer()
                    .frame(height: tabBarHeight + bottomPadding)
            }
            .ignoresSafeArea(.all, edges: [.leading, .trailing, .bottom])
        }
    }
}

// MARK: - MapCellView (Fixed)

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
        
        let hSpan = max(Int(activeBar.cellSpanHorizontal), 1)
        let vSpan = max(Int(activeBar.cellSpanVertical), 1)
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

#Preview {
    MapGridView(
        highlightedBarUUID: nil,
        showEnglish: false,
        onBarSelected: { _ in },
        onHighlightChange: { _ in }
    )
}
