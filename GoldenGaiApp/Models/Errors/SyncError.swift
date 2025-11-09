import Foundation

enum SyncError: LocalizedError {
    case authenticationFailed
    case timeoutError
    case partialSync(successful: Int, failed: Int)
    case noInternetConnection
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Authentication failed"
        case .timeoutError:
            return "Operation timed out"
        case .partialSync(let s, let f):
            return "Partial sync: \(s) successful, \(f) failed"
        case .noInternetConnection:
            return "No internet connection"
        case .invalidResponse:
            return "Invalid server response"
        }
    }
}
