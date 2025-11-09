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
    
    func checkFirstLaunch() {
        // Show welcome only on first launch
        if preferencesRepository.isLoggedIn {
            showWelcome = false
        }
    }
    
    func switchTab(_ tab: Int) {
        selectedTab = tab
    }
    
    func dismissWelcome() {
        showWelcome = false
    }
}
