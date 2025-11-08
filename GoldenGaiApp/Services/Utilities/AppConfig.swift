import Foundation

struct AppConfig {
    // Appwrite Configuration (Use your existing keys!)
    static let appwriteProjectID = ProcessInfo.processInfo.environment["APPWRITE_PROJECT_ID"] ?? "YOUR_PROJECT_ID"
    static let appwriteAPIKey = ProcessInfo.processInfo.environment["APPWRITE_API_KEY"] ?? "YOUR_API_KEY"
    static let appwriteEndpoint = ProcessInfo.processInfo.environment["APPWRITE_ENDPOINT"] ?? "https://cloud.appwrite.io/v1"
    
    // Database Configuration
    static let databaseID = "YOUR_DB_ID"
    
    // Collections
    static let barsCollectionID = "YOUR_BARS_COLLECTION_ID"
    static let barInfoCollectionID = "YOUR_BAR_INFO_COLLECTION_ID"
    static let imagesCollectionID = "YOUR_IMAGES_COLLECTION_ID"
    static let commentsCollectionID = "YOUR_COMMENTS_COLLECTION_ID"
    
    // Storage
    static let imagesBucketID = "YOUR_IMAGES_BUCKET_ID"
    
    // Validation
    static let isConfigured: Bool = {
        return !appwriteProjectID.contains("YOUR_") &&
               !appwriteAPIKey.contains("YOUR_")
    }()
}
