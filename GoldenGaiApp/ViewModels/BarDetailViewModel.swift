import Foundation
import UIKit
import Combine
import SwiftUI

@MainActor
class BarDetailViewModel: ObservableObject {
    @Published var bar: Bar?
    @Published var barInfo: BarInfo?
    @Published var comments: [BarComment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let barRepository: BarRepository
    private let barInfoService: BarInfoService
    private let imageService: ImageService
    private let syncService: SyncService
    
    @MainActor
    init(
        bar: Bar? = nil,
        barRepository: BarRepository? = nil,
        barInfoService: BarInfoService? = nil,
        imageService: ImageService? = nil,
        syncService: SyncService? = nil
    ) {
        self.bar = bar
        self.barRepository = barRepository ?? CoreDataBarRepository.shared
        self.barInfoService = barInfoService ?? BarInfoService()
        self.imageService = imageService ?? ImageService()
        self.syncService = syncService ?? SyncService()
    }
    
    func loadBarDetails(uuid: String) {
        isLoading = true
        errorMessage = nil
        
        // Load bar from repository
        if bar == nil {
            bar = barRepository.fetchByUUID(uuid)
        }
        
        // Load bar info
        barInfo = barInfoService.getBarInfo(for: uuid)
        
        // Load comments
        if let barInfo = barInfo {
            comments = barInfo.comments
        }
        
        isLoading = false
    }
    
    func markVisited() throws {
        guard let bar = bar else { return }
        try barRepository.markVisited(bar.uuid ?? "", timestamp: Date())
        self.bar?.visited = true
        self.bar?.visitedDate = Date()
    }
    
    func uploadPhoto(_ image: UIImage) async throws {
        guard let bar = bar, let uuid = bar.uuid else {
            throw BarError.invalidData("No bar selected")
        }
        
        let imageURL = try await imageService.uploadImage(image, for: uuid)
        try barRepository.addPhoto(uuid, photoURL: imageURL)
        if let currentURLs = self.bar?.photoURLs as? [String] {
            var updatedURLs = currentURLs
            updatedURLs.append(imageURL)
            self.bar?.photoURLs = updatedURLs as NSArray
        } else {
            self.bar?.photoURLs = [imageURL] as NSArray
        }
    }
        
        func addComment(_ content: String, language: Language) throws {
            guard let uuid = bar?.uuid else {
                throw BarError.invalidData("No bar selected")
            }
            
            try barRepository.addComment(uuid, comment: content, language: language.code)
        }
    }

