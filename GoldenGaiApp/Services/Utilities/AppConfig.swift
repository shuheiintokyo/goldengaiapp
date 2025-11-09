import UIKit
import Foundation
import CoreData
import Combine

struct AppConfig {
    // MARK: - Shared Instance
    
    static let shared = AppConfig()
    private static let loader = ConfigLoader.shared
    
    // MARK: - Appwrite Configuration
    
    var appwriteEndpoint: String {
        Self.loader.appwriteEndpoint
    }
    
    var appwriteProjectID: String {
        Self.loader.appwriteProjectID
    }
    
    var appwriteDatabaseID: String {
        Self.loader.appwriteDatabaseID
    }
    
    var appwriteCollectionID: String {
        Self.loader.appwriteCollectionID
    }
    
    var appwriteAPIKey: String {
        Self.loader.appwriteAPIKey
    }
    
    // MARK: - Convenience Properties
    
    var isConfigured: Bool {
        Self.loader.isConfigured
    }
    
    var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    // MARK: - App Information
    
    var appName: String {
        "GoldenGaiHopper"
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "com.shuheiintokyo.goldengaihopper"
    }
    
    // MARK: - Feature Flags
    
    var enableCloudSync: Bool {
        isConfigured
    }
    
    var enablePhotoUpload: Bool {
        true
    }
    
    var enableComments: Bool {
        true
    }
    
    // MARK: - Logging
    
    static func logConfiguration() {
        let config = AppConfig.shared
        print("""
        ═══════════════════════════════════════
        ⚙️ App Configuration:
        ───────────────────────────────────────
        App Name: \(config.appName)
        Version: \(config.appVersion)
        Bundle ID: \(config.bundleIdentifier)
        Environment: \(config.isProduction ? "Production" : "Development")
        Appwrite Configured: \(config.isConfigured ? "✅ Yes" : "⚠️ No")
        ═══════════════════════════════════════
        """)
        
        if config.isConfigured {
            Self.loader.logConfiguration()
        } else {
            print("⚠️ Warning: Appwrite not fully configured. Check Config.plist")
        }
    }
    
    // MARK: - Validation
    
    static func validateConfiguration() -> [String] {
        var errors: [String] = []
        let config = AppConfig.shared
        
        if config.appwriteProjectID.isEmpty {
            errors.append("APPWRITE_PROJECT_ID is not set")
        }
        
        if config.appwriteAPIKey.isEmpty {
            errors.append("APPWRITE_API_KEY is not set")
        }
        
        if config.appwriteDatabaseID.isEmpty {
            errors.append("APPWRITE_DATABASE_ID is not set")
        }
        
        if !errors.isEmpty {
            print("❌ Configuration validation failed:")
            errors.forEach { print("   - \($0)") }
        } else {
            print("✅ Configuration validation passed")
        }
        
        return errors
    }
}
