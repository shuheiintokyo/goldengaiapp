import Foundation
import CoreData

@objc(Bar)
public class Bar: NSManagedObject, Identifiable {
    public var id: String {
        self.uuid ?? UUID().uuidString
    }
}

// MARK: - Codable Support

extension Bar: Codable {
    enum CodingKeys: String, CodingKey {
        case uuid
        case name
        case nameJapanese
        case latitude
        case longitude
        case visited
        case visitedDate
        case photoURLs
        case tags
        case lastSyncedDate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(name, forKey: .name)
        try container.encode(nameJapanese, forKey: .nameJapanese)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(visited, forKey: .visited)
        try container.encode(visitedDate, forKey: .visitedDate)
        try container.encode(photoURLs, forKey: .photoURLs)
        try container.encode(tags, forKey: .tags)
        try container.encode(lastSyncedDate, forKey: .lastSyncedDate)
    }
    
    public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey(rawValue: "context") as CodingUserInfoKey] as? NSManagedObjectContext else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Missing managed object context"))
        }
        
        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(String.self, forKey: .uuid)
        name = try values.decode(String.self, forKey: .name)
        nameJapanese = try values.decode(String.self, forKey: .nameJapanese)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        visited = try values.decode(Bool.self, forKey: .visited)
        visitedDate = try values.decodeIfPresent(Date.self, forKey: .visitedDate)
        photoURLs = try values.decode([String].self, forKey: .photoURLs)
        tags = try values.decode([String].self, forKey: .tags)
        lastSyncedDate = try values.decodeIfPresent(Date.self, forKey: .lastSyncedDate)
    }
}
