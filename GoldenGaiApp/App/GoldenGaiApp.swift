import SwiftUI

@main
struct GoldenGaiApp: App {
    @StateObject private var appState = AppState()
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
        }
    }
}
