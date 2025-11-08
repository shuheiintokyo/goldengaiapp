import Foundation

enum BarError: LocalizedError {
    case notFound(uuid: String)
    case failedToUpdate(reason: String)
    case syncFailed(String)
    case imageUploadFailed(String)
    case invalidData(String)
    case networkError(String)
    case coreDataError(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound(let uuid):
            return "Bar not found: \(uuid)"
        case .failedToUpdate(let reason):
            return "Failed to update bar: \(reason)"
        case .syncFailed(let reason):
            return "Sync failed: \(reason)"
        case .imageUploadFailed(let reason):
            return "Image upload failed: \(reason)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .coreDataError(let reason):
            return "Data storage error: \(reason)"
        }
    }
}
