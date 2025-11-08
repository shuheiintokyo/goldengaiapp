import Foundation

struct BarNameTranslation {
    static let translations: [String: [String: String]] = [
        "bar-001": [
            "en": "The Bar",
            "ja": "ザ・バー"
        ],
        "bar-002": [
            "en": "Cozy Corner",
            "ja": "コージーコーナー"
        ]
    ]
    
    static func getName(for barUUID: String, language: String) -> String {
        translations[barUUID]?[language] ?? "Unknown Bar"
    }
}
