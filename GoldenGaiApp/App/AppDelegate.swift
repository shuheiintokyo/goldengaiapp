import UIKit
import CoreData

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
    
    // MARK: - Initial Data Seeding (IMPROVED)
    
    private func seedInitialDataIfNeeded() {
        let viewContext = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<Bar> = Bar.fetchRequest()
        
        do {
            let existingBars = try viewContext.fetch(fetchRequest)
            
            if existingBars.isEmpty {
                print("🌱 Starting data seeding...")
                
                // Load map.json
                guard let mapURL = Bundle.main.url(forResource: "map", withExtension: "json") else {
                    print("❌ map.json not found in bundle")
                    return
                }
                
                do {
                    let mapData = try Data(contentsOf: mapURL)
                    let mapJSON = try JSONSerialization.jsonObject(with: mapData) as? [String: Any]
                    
                    guard let mapArray = mapJSON?["map"] as? [[String]] else {
                        print("❌ Invalid map structure in map.json")
                        return
                    }
                    
                    var barCount = 0
                    var uuidMap: [String: String] = [:]  // barName -> uuid for reference
                    
                    print("📍 Parsing map with \(mapArray.count) rows...")
                    
                    // Parse map and create bars
                    for (row, rowData) in mapArray.enumerated() {
                        for (col, barName) in rowData.enumerated() {
                            // Skip empty cells and placeholders
                            if barName.isEmpty || barName == "*" {
                                continue
                            }
                            
                            let bar = Bar(context: viewContext)
                            let barUUID = UUID().uuidString
                            
                            bar.uuid = barUUID
                            bar.name = barName
                            bar.nameJapanese = barName  // TODO: Load from barinfo.json
                            bar.locationRow = Int16(row)
                            bar.locationColumn = Int16(col)
                            bar.cellSpanHorizontal = 1
                            bar.cellSpanVertical = 1
                            bar.visited = false
                            bar.photoURLs = []
                            bar.tags = []
                            bar.lastSyncedDate = Date()
                            
                            uuidMap[barName] = barUUID
                            barCount += 1
                        }
                    }
                    
                    // Save to Core Data
                    if barCount > 0 {
                        try viewContext.save()
                        print("✅ Successfully seeded \(barCount) bars into Core Data")
                    } else {
                        print("⚠️ No bars were created from map")
                    }
                    
                } catch let parseError as NSError {
                    print("❌ Error parsing map.json: \(parseError.localizedDescription)")
                    print("   Error domain: \(parseError.domain)")
                    print("   Error code: \(parseError.code)")
                }
                
            } else {
                print("✅ Database already seeded with \(existingBars.count) bars")
            }
        } catch {
            print("❌ Error checking existing bars: \(error.localizedDescription)")
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
