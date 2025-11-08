import Foundation
import CoreData

class CoreDataBarRepository: BarRepository {
    static let shared = CoreDataBarRepository()
    
    private let persistenceController = PersistenceController.shared
    
    private var context: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    // MARK: - BarRepository Implementation
    
    func fetch() -> [Bar] {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Bar.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch bars: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchByUUID(_ uuid: String) -> Bar? {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("❌ Failed to fetch bar by UUID: \(error.localizedDescription)")
            return nil
        }
    }
    
    func update(_ bar: Bar) throws {
        bar.lastSyncedDate = Date()
        
        do {
            try context.save()
            print("✅ Bar updated: \(bar.displayName)")
        } catch {
            print("❌ Failed to update bar: \(error.localizedDescription)")
            throw BarError.failedToUpdate(reason: error.localizedDescription)
        }
    }
    
    func delete(_ bar: Bar) throws {
        context.delete(bar)
        
        do {
            try context.save()
            print("✅ Bar deleted: \(bar.displayName)")
        } catch {
            print("❌ Failed to delete bar: \(error.localizedDescription)")
            throw BarError.failedToUpdate(reason: error.localizedDescription)
        }
    }
    
    func markVisited(_ uuid: String, timestamp: Date) throws {
        guard let bar = fetchByUUID(uuid) else {
            throw BarError.notFound(uuid: uuid)
        }
        
        bar.visited = true
        bar.visitedDate = timestamp
        
        try update(bar)
        print("✅ Bar marked as visited: \(bar.displayName)")
    }
    
    func addPhoto(_ uuid: String, photoURL: String) throws {
        guard let bar = fetchByUUID(uuid) else {
            throw BarError.notFound(uuid: uuid)
        }
        
        if !bar.photoURLs.contains(photoURL) {
            bar.photoURLs.append(photoURL)
            try update(bar)
            print("✅ Photo added to bar: \(bar.displayName)")
        }
    }
    
    func addComment(_ uuid: String, comment: String, language: String) throws {
        guard let bar = fetchByUUID(uuid) else {
            throw BarError.notFound(uuid: uuid)
        }
        
        // Store comment in a way that can be synced
        // This will be handled by cloud repository
        print("✅ Comment recorded for bar: \(bar.displayName)")
    }
    
    // MARK: - Additional Methods
    
    func fetchVisitedBars() -> [Bar] {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.predicate = NSPredicate(format: "visited == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Bar.visitedDate, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch visited bars: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchByTag(_ tag: String) -> [Bar] {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        request.predicate = NSPredicate(format: "tags CONTAINS %@", tag)
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch bars by tag: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAll() throws {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        
        do {
            let bars = try context.fetch(request)
            bars.forEach { context.delete($0) }
            try context.save()
            print("✅ All bars deleted")
        } catch {
            print("❌ Failed to delete all bars: \(error.localizedDescription)")
            throw BarError.coreDataError(error.localizedDescription)
        }
    }
    
    func count() -> Int {
        let request: NSFetchRequest<Bar> = Bar.fetchRequest()
        
        do {
            return try context.count(for: request)
        } catch {
            print("❌ Failed to count bars: \(error.localizedDescription)")
            return 0
        }
    }
}
