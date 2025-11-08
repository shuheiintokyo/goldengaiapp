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
        print("⏭️ Full sync skipped (local dev mode)")
        isSyncing = false
        lastSyncDate = Date()
    }
    
    func syncBars() async throws {
        print("⏭️ syncBars() skipped (local dev mode)")
    }
    
    func syncBarInfo() async throws {
        print("⏭️ syncBarInfo() skipped (local dev mode)")
    }
    
    func syncImages() async throws {
        print("⏭️ syncImages() skipped (local dev mode)")
    }
    
    // MARK: - Incremental Sync
    
    func incrementalSync() async throws {
        print("⏭️ Incremental sync skipped (local dev mode)")
    }
    
    // MARK: - Specific Sync Operations
    
    func syncBar(_ bar: Bar) async throws {
        print("⏭️ syncBar() skipped (local dev mode)")
    }
    
    func uploadBarPhoto(_ imageData: Data, for uuid: String) async throws -> String {
        print("⏭️ uploadBarPhoto() skipped (local dev mode)")
        return "local://\(uuid)"
    }
    
    // MARK: - Retry Logic
    
    func retryFailedSync() async throws {
        print("⏭️ retryFailedSync() skipped (local dev mode)")
    }
    
    // MARK: - Status Helpers
    
    func getSyncStatus() -> String {
        return "Local dev mode (sync disabled)"
    }
    
    func getTimeSinceLastSync() -> TimeInterval? {
        guard let lastSync = lastSyncDate else { return nil }
        return Date().timeIntervalSince(lastSync)
    }
    
    func shouldAutoSync() -> Bool {
        return false
    }
    
    // MARK: - Clear & Reset
    
    func clearSyncData() {
        lastSyncDate = nil
        syncError = nil
        syncProgress = 0.0
        print("✅ Sync data cleared (local dev mode)")
    }
}
