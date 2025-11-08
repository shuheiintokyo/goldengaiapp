import Foundation
import CoreData

struct CoreDataStack {
    static let shared = CoreDataStack()
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    init(modelName: String = "GoldenGaiApp") {
        let container = NSPersistentContainer(name: modelName)
        
        // Configure for better performance
        let description = container.persistentStoreDescriptions.first
        description?.shouldAddStoreAsyncually = false
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("❌ Core Data Error: \(error), \(error.userInfo)")
                fatalError("Unable to load persistent stores: \(error)")
            }
            print("✅ Core Data Store loaded: \(storeDescription.url?.lastPathComponent ?? "Unknown")")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        self.persistentContainer = container
    }
    
    // MARK: - Saving
    
    func save(context: NSManagedObjectContext? = nil) throws {
        let context = context ?? viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Save error: \(nsError), \(nsError.userInfo)")
                throw BarError.coreDataError(nsError.localizedDescription)
            }
        }
    }
    
    // MARK: - Background Context
    
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) -> T) -> Future<T, Error> {
        Future { promise in
            let context = persistentContainer.newBackgroundContext()
            context.perform {
                let result = block(context)
                promise(.success(result))
            }
        }
    }
    
    // MARK: - Background Save
    
    func saveBackgroundContext(_ block: @escaping (NSManagedObjectContext) -> Void) async throws {
        let context = persistentContainer.newBackgroundContext()
        
        await context.perform {
            block(context)
        }
        
        do {
            try save(context: context)
        } catch {
            print("❌ Background save error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Fetch Request Helpers
    
    func fetch<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>, in context: NSManagedObjectContext? = nil) throws -> [T] {
        let context = context ?? viewContext
        return try context.fetch(request)
    }
    
    func count<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>, in context: NSManagedObjectContext? = nil) throws -> Int {
        let context = context ?? viewContext
        return try context.count(for: request)
    }
    
    // MARK: - Reset
    
    func deleteAllData() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Bar.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeCount
        
        do {
            let result = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            print("✅ Deleted \(result?.result ?? 0) records")
            try save()
        } catch {
            print("❌ Delete error: \(error.localizedDescription)")
            throw BarError.coreDataError(error.localizedDescription)
        }
    }
    
    // MARK: - Migration & Maintenance
    
    func validateObjectStore() -> Bool {
        do {
            let request: NSFetchRequest<Bar> = Bar.fetchRequest()
            request.returnsObjectsAsFaults = true
            let count = try viewContext.count(for: request)
            print("✅ Object store validated: \(count) bars")
            return true
        } catch {
            print("❌ Object store validation failed: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - Future Implementation (if using Combine)

import Combine

struct Future<Output, Failure: Error>: Publisher {
    typealias Output = Output
    typealias Failure = Failure
    
    private let attemptToFulfill: (@escaping (Result<Output, Failure>) -> Void) -> Void
    
    init(_ attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void) {
        self.attemptToFulfill = attemptToFulfill
    }
    
    func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        let subscription = FutureSubscription(attemptToFulfill: attemptToFulfill, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private class FutureSubscription<Output, Failure: Error, S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
    private var cancelled = false
    
    init(attemptToFulfill: @escaping (@escaping (Result<Output, Failure>) -> Void) -> Void, subscriber: S) {
        attemptToFulfill { result in
            if !self.cancelled {
                switch result {
                case .success(let output):
                    _ = subscriber.receive(output)
                case .failure(let error):
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
        cancelled = true
    }
}
