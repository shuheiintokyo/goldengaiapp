import SwiftUI

@main
struct GoldenGaiApp: App {
    // Use AppDelegate for app lifecycle management
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appState = AppState.shared
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .onAppear {
                    // Log configuration on first appearance
                    AppConfig.logConfiguration()
                    logDatabaseStatus()
                }
        }
    }
    
    // MARK: - Logging
    
    private func logDatabaseStatus() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        
        do {
            let count = try context.count(for: request)
            print("""
            ═══════════════════════════════════════
            📊 Database Status:
            ───────────────────────────────────────
            Total Bars: \(count)
            ═══════════════════════════════════════
            """)
        } catch {
            print("❌ Error fetching bar count: \(error.localizedDescription)")
        }
    }
}
