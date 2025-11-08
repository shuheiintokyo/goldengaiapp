import Foundation

struct ConfigLoader {
    static let shared = ConfigLoader()
    
    private let configDictionary: [String: Any]
    
    init() {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("⚠️ Warning: Config.plist not found, using defaults")
            self.configDictionary = [:]
            return
        }
        self.configDictionary = dict
        print("✅ Config.plist loaded successfully")
    }
    
    // MARK: - Appwrite Configuration
    
    var appwriteEndpoint: String {
        configDictionary["APPWRITE_ENDPOINT"] as? String ??
            "https://cloud.appwrite.io/v1"
    }
    
    var appwriteProjectID: String {
        configDictionary["APPWRITE_PROJECT_ID"] as? String ?? ""
    }
    
    var appwriteDatabaseID: String {
        configDictionary["APPWRITE_DATABASE_ID"] as? String ?? ""
    }
    
    var appwriteCollectionID: String {
        configDictionary["APPWRITE_COLLECTION_ID"] as? String ?? "bar-info"
    }
    
    var appwriteAPIKey: String {
        configDictionary["APPWRITE_API_KEY"] as? String ?? ""
    }
    
    // MARK: - Validation
    
    var isConfigured: Bool {
        !appwriteProjectID.isEmpty && !appwriteAPIKey.isEmpty
    }
    
    func logConfiguration() {
        print("""
        ═══════════════════════════════════════
        📋 Appwrite Configuration:
        ───────────────────────────────────────
        Endpoint: \(appwriteEndpoint)
        Project ID: \(appwriteProjectID.prefix(8))...
        Database ID: \(appwriteDatabaseID.prefix(8))...
        Collection ID: \(appwriteCollectionID)
        API Key: \(appwriteAPIKey.isEmpty ? "NOT SET ⚠️" : "✓")
        ═══════════════════════════════════════
        """)
    }
}
