import SwiftUI
import UIKit
import Combine
import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var showEnglish = false
    @Published var lastSyncDate: Date?
    @Published var contentViewBackground = "ContentBackground"
    @Published var barListViewBackground = "BarListBackground"
    @Published var mapViewBackground = "BarMapBackground"
    @Published var isSyncing = false
    @Published var syncError: String?
    
    private var preferencesRepository: PreferencesRepository
    private let syncService: SyncService
    
    // FIXED: Add @MainActor to init to ensure thread safety
    @MainActor
    init(
        preferencesRepository: PreferencesRepository = AppStoragePreferencesRepository.shared,
        syncService: SyncService? = nil
    ) {
        self.preferencesRepository = preferencesRepository
        self.syncService = syncService ?? SyncService()
        loadSettings()
        print("✅ SettingsViewModel initialized on MainActor")
    }
    
    func loadSettings() {
        isLoggedIn = preferencesRepository.isLoggedIn
        showEnglish = preferencesRepository.showEnglish
        lastSyncDate = preferencesRepository.lastSyncDate
        contentViewBackground = preferencesRepository.backgroundPreference
    }
    
    func updateLanguage(_ english: Bool) {
        showEnglish = english
        preferencesRepository.showEnglish = english
        preferencesRepository.save()
        print("✅ Language updated: \(english ? "English" : "Japanese")")
    }
    
    func updateBackground(_ name: String, for view: String) {
        preferencesRepository.backgroundPreference = name
        preferencesRepository.save()
        print("✅ Background updated for \(view): \(name)")
    }
    
    func performSync() async {
        isSyncing = true
        syncError = nil
        
        do {
            try await syncService.performFullSync()
            lastSyncDate = syncService.lastSyncDate
            print("✅ Sync completed successfully")
        } catch {
            syncError = (error as? LocalizedError)?.errorDescription ?? "Sync failed"
            print("❌ Sync failed: \(syncError ?? "Unknown error")")
        }
        
        isSyncing = false
    }
    
    func logout() {
        preferencesRepository.logout()
        isLoggedIn = false
        print("✅ User logged out")
    }
}
