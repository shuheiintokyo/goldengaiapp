import UIKit
import Foundation
import CoreData
import Combine

// MARK: - Transformable Codable Value Transformer

@objc(CodableValueTransformer)
class CodableValueTransformer: NSSecureUnarchiveFromDataTransformer {
    
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self]
    }
    
    static let name = NSValueTransformerName(rawValue: String(describing: CodableValueTransformer.self))
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data)
        } catch {
            print("❌ Error unarchiving: \(error)")
            return nil
        }
    }
}

// MARK: - Array Extension for JSON Encoding

extension Array where Element: Codable {
    /// Convert array to JSON data for Core Data storage
    func toJSONData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    /// Create array from JSON data
    static func fromJSONData(_ data: Data?) -> [Element]? {
        guard let data = data else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Element].self, from: data)
    }
}

// MARK: - String Array Helper

extension Array where Element == String {
    /// Convert string array to JSON for Core Data
    func toJSON() -> String? {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return nil
        }
        return json
    }
    
    /// Create string array from JSON
    static func fromJSON(_ json: String?) -> [String]? {
        guard let json = json,
              let data = json.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode([String].self, from: data)
    }
}

// MARK: - Core Data Setup Helper

class TransformerRegistration {
    static func registerTransformers() {
        let transformer = CodableValueTransformer()
        ValueTransformer.setValueTransformer(
            transformer,
            forName: CodableValueTransformer.name
        )
        print("✅ Value transformers registered")
    }
}

// MARK: - Migration Helper

struct CoreDataMigration {
    /// Handle array-to-transformable migration for existing databases
    static func migrateArrayAttributes(
        in context: NSManagedObjectContext
    ) throws {
        let fetchRequest: NSFetchRequest<Bar> = Bar.fetchRequest()
        let bars = try context.fetch(fetchRequest)
        
        for bar in bars {
            // Ensure arrays are properly formatted
            if bar.photoURLs == nil || bar.photoURLs?.count == 0 {
                bar.photoURLs = [] as NSArray
            }
            if bar.tags == nil || bar.tags?.count == 0 {
                bar.tags = [] as NSArray
            }
        }
        
        try context.save()
        print("✅ Array attributes migrated successfully")
    }
}
