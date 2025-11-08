import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    
    let persistenceController = PersistenceController.shared
    
    // MARK: - UIApplicationDelegate Methods
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure Core Data
        setupCoreData()
        
        // Configure app appearance
        configureAppearance()
        
        // Seed initial data if needed
        seedInitialDataIfNeeded()
        
        print("✅ App launched successfully")
        return true
    }
    
    // MARK: - UISceneDelegate Stubs
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Handle discarded scenes
    }
    
    // MARK: - Core Data Setup
    
    private func setupCoreData() {
        let viewContext = persistenceController.container.viewContext
        
        // Configure context settings
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Enable undo/redo
        viewContext.undoManager = UndoManager()
        
        print("✅ Core Data initialized")
    }
    
    // MARK: - Appearance Configuration
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Configure tab bar appearance if needed
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        print("✅ Appearance configured")
    }
    
    // MARK: - Initial Data Seeding
    
    private func seedInitialDataIfNeeded() {
        let viewContext = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Bar> = Bar.fetchRequest()
        
        do {
            let existingBars = try viewContext.fetch(fetchRequest)
            if existingBars.isEmpty {
                print("🌱 Seeding initial bar data...")
                DataSeeder.seedInitialBars(into: viewContext)
                try viewContext.save()
                print("✅ Initial data seeded successfully")
            } else {
                print("✅ Database already contains \(existingBars.count) bars")
            }
        } catch {
            print("❌ Error checking for initial data: \(error.localizedDescription)")
        }
    }
}

// MARK: - Scene Delegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // This is handled by SwiftUI @main
    }
}
