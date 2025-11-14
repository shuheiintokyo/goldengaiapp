import Foundation
import CoreData
import SwiftUI
import UIKit

struct MapView: View {
    @State private var selectedBar: Bar?
    @State private var highlightedBarUUID: String?
    
    var body: some View {
        ZStack {
            DynamicBackgroundImage(imageName: "BarMapBackground")
                .ignoresSafeArea()
            
            MapGridView(
                highlightedBarUUID: highlightedBarUUID,
                onBarSelected: { bar in
                    selectedBar = bar
                }
            )
        }
        .sheet(item: $selectedBar) { bar in
            NavigationStack {
                BarDetailView(bar: bar)
            }
        }
    }
}
