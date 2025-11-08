import Foundation

@MainActor
protocol PreferencesRepository {
    var isLoggedIn: Bool { get set }
    var showEnglish: Bool { get set }
    var lastSyncDate: Date? { get set }
    var backgroundPreference: String { get set }
    
    func save()
    func load()
}
