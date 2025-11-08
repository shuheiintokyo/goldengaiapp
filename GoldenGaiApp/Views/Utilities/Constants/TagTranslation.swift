import Foundation

struct TagTranslation {
    static let translations: [String: [String: String]] = [
        "intimate": ["en": "Intimate", "ja": "親密"],
        "historic": ["en": "Historic", "ja": "歴史的"],
        "cozy": ["en": "Cozy", "ja": "くつろぐ"],
        "friendly": ["en": "Friendly", "ja": "フレンドリー"],
        "whisky": ["en": "Whisky", "ja": "ウイスキー"]
    ]
    
    static func getTranslation(_ tag: String, language: String) -> String {
        translations[tag]?[language] ?? tag
    }
}
