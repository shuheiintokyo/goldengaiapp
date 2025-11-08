import Foundation

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
    
    init(
        bar: Bar? = nil,
        barRepository: BarRepository = CoreDataBarRepository.shared,
        barInfoService: BarInfoService = BarInfoService(),
        imageService: ImageService = ImageService(),
        syncService: SyncService = SyncService()
    ) {
        self.bar = bar
        self.barRepository = barRepository
        self.barInfoService = barInfoService
        self.imageService = imageService
        self.syncService = syncService
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
        self.bar?.photoURLs.append(imageURL)
    }
    
    func addComment(_ content: String, language: Language) throws {
        guard let bar = bar, let uuid = bar.uuid else {
            throw BarError.invalidData("No bar selected")
        }
        
        try barRepository.addComment(uuid, comment: content, language: language.code)
    }
}
