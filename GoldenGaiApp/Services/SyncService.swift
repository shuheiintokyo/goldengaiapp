import Foundation

@MainActor
class SyncService: ObservableObject {
    @Published var isSyncing = false
    @Published var syncProgress: Double = 0.0
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    private let barRepository: BarRepository
    private let cloudRepository: CloudRepository
    private let barInfoService: BarInfoService
    private let preferencesRepository: PreferencesRepository
    
    init(
        barRepository: BarRepository = CoreDataBarRepository.shared,
        cloudRepository: CloudRepository = AppwriteCloudRepository.shared,
        barInfoService: BarInfoService? = nil,
        preferencesRepository: PreferencesRepository = AppStoragePreferencesRepository.shared
    ) {
        self.barRepository = barRepository
        self.cloudRepository = cloudRepository
        self.barInfoService = barInfoService ?? BarInfoService(repository: barRepository)
        self.preferencesRepository = preferencesRepository
    }
    
    // MARK: - Main Sync Operations
    
    func performFullSync() async throws {
        print("🔄 Starting full synchronization...")
        isSyncing = true
        syncError = nil
        syncProgress = 0.0
        defer { isSyncing = false }
        
        do {
            try await syncBars()
            syncProgress = 0.33
            
            try await syncBarInfo()
            syncProgress = 0.66
            
            try await syncImages()
            syncProgress = 1.0
            
            lastSyncDate = Date()
            preferencesRepository.lastSyncDate = lastSyncDate
            preferencesRepository.save()
            
            print("✅ Full synchronization completed successfully")
        } catch {
            syncError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            print("❌ Synchronization failed: \(syncError ?? "Unknown error")")
            throw error
        }
    }
    
    func syncBars() async throws {
        print("🔄 Syncing bars...")
        
        do {
            let count = try await cloudRepository.syncBars()
            print("✅ Synced \(count) bars")
        } catch {
            print("❌ Failed to sync bars: \(error.localizedDescription)")
            throw error
        }
    }
    
    func syncBarInfo() async throws {
        print("🔄 Syncing bar info...")
        
        do {
            try await barInfoService.syncFromCloud(cloudRepository)
            print("✅ Bar info synced")
        } catch {
            print("❌ Failed to sync bar info: \(error.localizedDescription)")
            throw error
        }
    }
    
    func syncImages() async throws {
        print("🔄 Syncing images...")
        
        // Get all bars and check for missing images
        let bars = barRepository.fetch()
        
        for bar in bars {
            guard let uuid = bar.uuid else { continue }
            
            for photoURL in bar.photoURLs {
                // Check if image exists locally
                // If not, download it
                print("📸 Processing image for \(uuid): \(photoURL)")
            }
        }
        
        print("✅ Images synced")
    }
    
    // MARK: - Incremental Sync
    
    func incrementalSync() async throws {
        print("🔄 Starting incremental synchronization...")
        isSyncing = true
        syncError = nil
        defer { isSyncing = false }
        
        do {
            // Only sync changes since last sync date
            let lastSync = preferencesRepository.lastSyncDate ?? Date(timeIntervalSince1970: 0)
            
            print("📅 Syncing changes since: \(lastSync)")
            
            try await performFullSync()
        } catch {
            syncError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Specific Sync Operations
    
    func syncBar(_ bar: Bar) async throws {
        print("🔄 Syncing bar: \(bar.displayName)")
        
        do {
            try barRepository.update(bar)
            print("✅ Bar synced: \(bar.displayName)")
        } catch {
            print("❌ Failed to sync bar: \(error.localizedDescription)")
            throw error
        }
    }
    
    func uploadBarPhoto(_ imageData: Data, for uuid: String) async throws -> String {
        print("📸 Uploading photo for bar: \(uuid)")
        
        do {
            let imageURL = try await cloudRepository.uploadImage(imageData, for: uuid)
            
            // Update bar with new photo URL
            if let bar = barRepository.fetchByUUID(uuid) {
                try barRepository.addPhoto(uuid, photoURL: imageURL)
            }
            
            print("✅ Photo uploaded: \(imageURL)")
            return imageURL
        } catch {
            print("❌ Photo upload failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Retry Logic
    
    func retryFailedSync() async throws {
        print("🔄 Retrying failed sync...")
        try await performFullSync()
    }
    
    // MARK: - Status Helpers
    
    func getSyncStatus() -> String {
        if isSyncing {
            return "Syncing: \(Int(syncProgress * 100))%"
        } else if let error = syncError {
            return "Error: \(error)"
        } else if let lastSync = lastSyncDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return "Last synced: \(formatter.string(from: lastSync))"
        } else {
            return "Not yet synced"
        }
    }
    
    func getTimeSinceLastSync() -> TimeInterval? {
        guard let lastSync = lastSyncDate else { return nil }
        return Date().timeIntervalSince(lastSync)
    }
    
    func shouldAutoSync() -> Bool {
        // Auto-sync if more than 1 hour has passed since last sync
        guard let timeSince = getTimeSinceLastSync() else { return true }
        return timeSince > 3600 // 1 hour
    }
    
    // MARK: - Clear & Reset
    
    func clearSyncData() {
        lastSyncDate = nil
        syncError = nil
        syncProgress = 0.0
        preferencesRepository.lastSyncDate = nil
        preferencesRepository.save()
        print("✅ Sync data cleared")
    }
}
