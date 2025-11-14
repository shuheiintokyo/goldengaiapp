import UIKit
import Foundation
import CoreData
import Combine

@MainActor
class BarInfoService: ObservableObject {
    @Published var barInfoCache: [String: BarInfo] = [:]
    @Published var isLoading = false
    
    private let repository: BarRepository
    private var barInfoFromJSON: [String: BarInfo] = [:]
    
    init(repository: BarRepository = CoreDataBarRepository.shared) {
        self.repository = repository
        loadBarInfoFromBundle()
    }
    
    // MARK: - Load from Bundle
    
    private func loadBarInfoFromBundle() {
        // Load barinfo.json from bundle
        guard let url = Bundle.main.url(forResource: "barinfo", withExtension: "json") else {
            print("⚠️ barinfo.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Assuming barinfo.json contains a dictionary of [String: BarInfo]
            let decoded = try decoder.decode([String: BarInfo].self, from: data)
            barInfoFromJSON = decoded
            
            // Cache all loaded info
            barInfoCache = decoded
            
            print("✅ Loaded \(decoded.count) bar info from bundle")
        } catch {
            print("❌ Failed to load barinfo.json: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Query Methods
    
    func getBarInfo(for uuid: String) -> BarInfo? {
        // Check cache first
        if let cached = barInfoCache[uuid] {
            return cached
        }
        
        // Check JSON
        if let fromJSON = barInfoFromJSON[uuid] {
            barInfoCache[uuid] = fromJSON
            return fromJSON
        }
        
        return nil
    }
    
    func getAllBarInfo() -> [String: BarInfo] {
        return barInfoCache.isEmpty ? barInfoFromJSON : barInfoCache
    }
    
    func getComments(for uuid: String, language: Language) -> [BarComment] {
        guard let barInfo = getBarInfo(for: uuid) else {
            return []
        }
        
        return barInfo.comments.filter { $0.language == language }
    }
    
    // MARK: - Cloud Sync
    
    func syncFromCloud(_ cloudRepository: CloudRepository) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let count = try await cloudRepository.syncBarInfo()
            print("✅ Synced \(count) bar info from cloud")
        } catch {
            print("❌ Failed to sync bar info: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Update Methods
    
    func updateBarInfo(_ info: BarInfo) {
        barInfoCache[info.id] = info
        print("✅ Bar info updated: \(info.id)")
    }
    
    func addComment(to uuid: String, comment: BarComment) {
        guard var barInfo = barInfoCache[uuid] else {
            print("⚠️ Bar info not found: \(uuid)")
            return
        }
        
        barInfo.comments.append(comment)
        updateBarInfo(barInfo)
        print("✅ Comment added to bar: \(uuid)")
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        barInfoCache.removeAll()
        print("✅ Bar info cache cleared")
    }
    
    func reloadFromBundle() {
        barInfoCache.removeAll()
        loadBarInfoFromBundle()
    }
    
    func getCacheSize() -> Int {
        return barInfoCache.count
    }
}
