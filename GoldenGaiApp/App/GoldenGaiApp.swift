@main
struct GoldenPeaceApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var eventBus = EventBus()
    
    let persistenceController = PersistenceController.shared
    let serviceContainer = ServiceContainer.shared
    
    init() {
        // Validate Appwrite configuration
        guard AppConfig.isConfigured else {
            print("⚠️ Appwrite not configured! Update AppConfig.swift")
            return
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(appState)
                    .environmentObject(eventBus)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
    }
}
