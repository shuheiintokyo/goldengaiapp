import Foundation

class AppwriteCloudRepository: CloudRepository {
    static let shared = AppwriteCloudRepository()
    
    private var isInitialized = false
    
    init() {
        initializeAppwrite()
    }
    
    private func initializeAppwrite() {
        print("⚠️ Appwrite stub mode - cloud sync disabled for local development")
        isInitialized = false
    }
    
    // MARK: - CloudRepository Implementation (Stub/No-op)
    
    func syncBars() async throws -> Int {
        print("⏭️ syncBars() - skipped (local dev mode)")
        return 0
    }
    
    func uploadImage(_ imageData: Data, for uuid: String) async throws -> String {
        print("⏭️ uploadImage() - skipped (local dev mode)")
        return "local://\(uuid)"
    }
    
    func syncBarInfo() async throws -> Int {
        print("⏭️ syncBarInfo() - skipped (local dev mode)")
        return 0
    }
    
    func getRemoteBarInfo(for uuid: String) async throws -> BarInfo? {
        print("⏭️ getRemoteBarInfo() - skipped (local dev mode)")
        return nil
    }
    
    // MARK: - Helper Methods
    
    func testConnection() async -> Bool {
        print("⏭️ testConnection() - skipped (local dev mode)")
        return false
    }
}
