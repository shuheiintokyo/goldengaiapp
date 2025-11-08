import Foundation
import CoreData
import UIKit

class MockBarRepository: BarRepository {
    var mockBars: [Bar] = []
    
    func fetch() -> [Bar] {
        return mockBars
    }
    
    func fetchByUUID(_ uuid: String) -> Bar? {
        return mockBars.first { $0.uuid == uuid }
    }
    
    func update(_ bar: Bar) throws {
        print("✅ Mock: Updated bar \(bar.displayName)")
    }
    
    func delete(_ bar: Bar) throws {
        mockBars.removeAll { $0.uuid == bar.uuid }
        print("✅ Mock: Deleted bar")
    }
    
    func markVisited(_ uuid: String, timestamp: Date) throws {
        if let bar = fetchByUUID(uuid) {
            bar.visited = true
            bar.visitedDate = timestamp
        }
    }
    
    func addPhoto(_ uuid: String, photoURL: String) throws {
        if let bar = fetchByUUID(uuid) {
            bar.photoURLs.append(photoURL)
        }
    }
    
    func addComment(_ uuid: String, comment: String, language: String) throws {
        print("✅ Mock: Added comment to bar \(uuid)")
    }
}

class MockCloudRepository: CloudRepository {
    var shouldFail = false
    
    func syncBars() async throws -> Int {
        if shouldFail {
            throw SyncError.noInternetConnection
        }
        print("✅ Mock: Synced bars")
        return 5
    }
    
    func uploadImage(_ imageData: Data, for uuid: String) async throws -> String {
        if shouldFail {
            throw SyncError.authenticationFailed
        }
        print("✅ Mock: Uploaded image for \(uuid)")
        return "https://mock.example.com/images/\(uuid).jpg"
    }
    
    func syncBarInfo() async throws -> Int {
        if shouldFail {
            throw SyncError.timeoutError
        }
        print("✅ Mock: Synced bar info")
        return 5
    }
    
    func getRemoteBarInfo(for uuid: String) async throws -> BarInfo? {
        print("✅ Mock: Fetched bar info for \(uuid)")
        return BarInfo.preview
    }
}

class MockImageRepository: ImageRepository {
    var mockImages: [String: UIImage] = [:]
    
    func save(_ image: UIImage, for uuid: String) throws {
        mockImages[uuid] = image
        print("✅ Mock: Saved image for \(uuid)")
    }
    
    func load(for uuid: String) -> UIImage? {
        print("✅ Mock: Loaded image for \(uuid)")
        return mockImages[uuid]
    }
    
    func delete(for uuid: String) throws {
        mockImages.removeValue(forKey: uuid)
        print("✅ Mock: Deleted image for \(uuid)")
    }
}

class MockPreferencesRepository: PreferencesRepository {
    @MainActor
    var isLoggedIn: Bool = false
    
    @MainActor
    var showEnglish: Bool = false
    
    @MainActor
    var lastSyncDate: Date?
    
    @MainActor
    var backgroundPreference: String = "ContentBackground"
    
    @MainActor
    func save() {
        print("✅ Mock: Saved preferences")
    }
    
    @MainActor
    func load() {
        print("✅ Mock: Loaded preferences")
    }
}

extension Bar {
    static var mockBars: [Bar] {
        let context = PersistenceController.preview.container.viewContext
        var bars: [Bar] = []
        
        let names = [
            ("The Bar", "ザ・バー"),
            ("Cozy Corner", "コージーコーナー"),
            ("Whisky Den", "ウイスキーデン")
        ]
        
        for (index, (name, jaName)) in names.enumerated() {
            let bar = Bar(context: context)
            bar.uuid = "bar-\(index)"
            bar.name = name
            bar.nameJapanese = jaName
            bar.visited = index % 2 == 0
            bar.tags = ["intimate", "historic"]
            bar.photoURLs = []
            bars.append(bar)
        }
        
        return bars
    }
}
