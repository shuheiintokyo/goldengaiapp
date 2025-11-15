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

