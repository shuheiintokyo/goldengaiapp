import Foundation

extension String {
    func localized(_ language: String) -> String {
        // Simple localization helper
        // In production, use Apple's Localizable.strings
        switch self {
        case "bars":
            return language == "ja" ? "バー" : "Bars"
        case "settings":
            return language == "ja" ? "設定" : "Settings"
        case "map":
            return language == "ja" ? "地図" : "Map"
        default:
            return self
        }
    }
}
