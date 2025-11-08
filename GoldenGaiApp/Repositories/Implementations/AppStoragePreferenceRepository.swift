import Foundation

@MainActor
class AppStoragePreferencesRepository: PreferencesRepository {
    static let shared = AppStoragePreferencesRepository()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Key {
        static let isLoggedIn = "pref_isLoggedIn"
        static let showEnglish = "pref_showEnglish"
        static let lastSyncDate = "pref_lastSyncDate"
        static let backgroundPreference = "pref_backgroundPreference"
        static let userEmail = "pref_userEmail"
        static let userId = "pref_userId"
        static let userToken = "pref_userToken"
    }
    
    // MARK: - PreferencesRepository Implementation
    
    var isLoggedIn: Bool {
        get {
            defaults.bool(forKey: Key.isLoggedIn)
        }
        set {
            defaults.set(newValue, forKey: Key.isLoggedIn)
        }
    }
    
    var showEnglish: Bool {
        get {
            defaults.bool(forKey: Key.showEnglish)
        }
        set {
            defaults.set(newValue, forKey: Key.showEnglish)
        }
    }
    
    var lastSyncDate: Date? {
        get {
            defaults.object(forKey: Key.lastSyncDate) as? Date
        }
        set {
            defaults.set(newValue, forKey: Key.lastSyncDate)
        }
    }
    
    var backgroundPreference: String {
        get {
            defaults.string(forKey: Key.backgroundPreference) ?? "ContentBackground"
        }
        set {
            defaults.set(newValue, forKey: Key.backgroundPreference)
        }
    }
    
    // MARK: - Additional User Properties
    
    var userEmail: String? {
        get {
            defaults.string(forKey: Key.userEmail)
        }
        set {
            defaults.set(newValue, forKey: Key.userEmail)
        }
    }
    
    var userId: String? {
        get {
            defaults.string(forKey: Key.userId)
        }
        set {
            defaults.set(newValue, forKey: Key.userId)
        }
    }
    
    var userToken: String? {
        get {
            defaults.string(forKey: Key.userToken)
        }
        set {
            defaults.set(newValue, forKey: Key.userToken)
        }
    }
    
    // MARK: - Save & Load
    
    func save() {
        defaults.synchronize()
        print("✅ Preferences saved")
    }
    
    func load() {
        // UserDefaults automatically loads at app launch
        print("✅ Preferences loaded")
    }
    
    // MARK: - Additional Methods
    
    func clearAllPreferences() {
        if let appDomain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: appDomain)
        }
        print("✅ All preferences cleared")
    }
    
    func logout() {
        isLoggedIn = false
        userEmail = nil
        userId = nil
        userToken = nil
        save()
        print("✅ User logged out")
    }
    
    func setLoginData(email: String, userId: String, token: String) {
        userEmail = email
        self.userId = userId
        userToken = token
        isLoggedIn = true
        save()
        print("✅ Login data saved")
    }
}
