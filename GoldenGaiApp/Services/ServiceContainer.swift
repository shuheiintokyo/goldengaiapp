import Foundation

@MainActor
class ServiceContainer {
    static let shared = ServiceContainer()
    
    let barRepository: BarRepository
    let cloudRepository: CloudRepository
    let imageRepository: ImageRepository
    let preferencesRepository: PreferencesRepository
    let barInfoService: BarInfoService
    let syncService: SyncService
    let imageService: ImageService
    let eventBus: EventBus
    
    init(
        barRepository: BarRepository? = nil,
        cloudRepository: CloudRepository? = nil,
        imageRepository: ImageRepository? = nil,
        preferencesRepository: PreferencesRepository? = nil
    ) {
        // Initialize repositories
        self.barRepository = barRepository ?? CoreDataBarRepository.shared
        self.cloudRepository = cloudRepository ?? AppwriteCloudRepository.shared
        self.imageRepository = imageRepository ?? FileSystemImageRepository.shared
        self.preferencesRepository = preferencesRepository ?? AppStoragePreferencesRepository.shared
        
        // Initialize services
        self.barInfoService = BarInfoService(repository: self.barRepository)
        self.syncService = SyncService(
            barRepository: self.barRepository,
            cloudRepository: self.cloudRepository,
            barInfoService: self.barInfoService
        )
        self.imageService = ImageService(
            imageRepository: self.imageRepository,
            cloudRepository: self.cloudRepository
        )
        self.eventBus = EventBus.shared
    }
}
