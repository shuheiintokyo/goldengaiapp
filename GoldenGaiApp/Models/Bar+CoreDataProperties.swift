import Foundation
import CoreData

// MARK: - Bar Properties Extension

extension Bar {
    
    @NSManaged public var uuid: String?
    @NSManaged public var name: String?
    @NSManaged public var nameJapanese: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var visited: Bool
    @NSManaged public var visitedDate: Date?
    @NSManaged public var photoURLs: [String]
    @NSManaged public var tags: [String]
    @NSManaged public var lastSyncedDate: Date?
    
    // MARK: - Convenience Properties
    
    var displayName: String {
        name ?? "Unknown Bar"
    }
    
    var displayNameJapanese: String {
        nameJapanese ?? "未知のバー"
    }
    
    var formattedVisitDate: String {
        guard let date = visitedDate else { return "Not visited" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return "Visited: \(formatter.string(from: date))"
    }
    
    var hasPhotos: Bool {
        !photoURLs.isEmpty
    }
    
    var photoCount: Int {
        photoURLs.count
    }
}

// MARK: - Fetch Request Helper

extension Bar {
    @NSManaged public var locationDistance: Double // Computed distance for sorting
    
    static func allBarsFetchRequest() -> NSFetchRequest<Bar> {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Bar.name, ascending: true)]
        return request
    }
    
    static func visitedBarsFetchRequest() -> NSFetchRequest<Bar> {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.predicate = NSPredicate(format: "visited == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Bar.visitedDate, ascending: false)]
        return request
    }
    
    static func nearbyBarsFetchRequest(latitude: Double, longitude: Double, radiusKm: Double = 1.0) -> NSFetchRequest<Bar> {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        let latDelta = radiusKm / 111.0 // Rough approximation: 1 degree latitude ≈ 111 km
        let request_predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "latitude >= %lf AND latitude <= %lf", latitude - latDelta, latitude + latDelta),
            NSPredicate(format: "longitude >= %lf AND longitude <= %lf", longitude - latDelta, longitude + latDelta)
        ])
        request.predicate = request_predicate
        return request
    }
}
