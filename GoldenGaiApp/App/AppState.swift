import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var showEnglish = false
    @Published var selectedTab = 0
    @Published var highlightedBarUUID: String?
    @Published var lastSyncDate: Date?
    
    // UI Customization
    @Published var contentViewBackground = "ContentBackground"
    @Published var barListViewBackground = "BarListBackground"
    @Published var mapViewBackground = "BarMapBackground"
    
    // Loading states
    @Published var isSyncing = false
    @Published var syncError: String?
    
    static let shared = AppState()
    
    init() {
        self.loadPersistedState()
    }
    
    private func loadPersistedState() {
        self.showEnglish = UserDefaults.standard.bool(forKey: "showEnglish")
        self.contentViewBackground = UserDefaults.standard.string(forKey: "ContentViewBackground") ?? "ContentBackground"
        self.barListViewBackground = UserDefaults.standard.string(forKey: "BarListViewBackground") ?? "BarListBackground"
        self.mapViewBackground = UserDefaults.standard.string(forKey: "MapViewBackground") ?? "BarMapBackground"
    }
    
    func persistState() {
        UserDefaults.standard.set(showEnglish, forKey: "showEnglish")
        UserDefaults.standard.set(contentViewBackground, forKey: "ContentViewBackground")
        UserDefaults.standard.set(barListViewBackground, forKey: "BarListViewBackground")
        UserDefaults.standard.set(mapViewBackground, forKey: "MapViewBackground")
    }
}
