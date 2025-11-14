import Foundation
import CoreData
import Combine
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var showWelcome = true
    
    private let preferencesRepository: PreferencesRepository
    
    init(preferencesRepository: PreferencesRepository = AppStoragePreferencesRepository.shared) {
        self.preferencesRepository = preferencesRepository
        checkFirstLaunch()
    }
    
    // FIXED: Proper first-launch detection with UserDefaults
    func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            showWelcome = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            print("✅ First launch - showing welcome")
        } else {
            showWelcome = false
            print("✅ Returning user - hiding welcome")
        }
    }
    
    func switchTab(_ tab: Int) {
        selectedTab = tab
    }
    
    func dismissWelcome() {
        showWelcome = false
    }
}
