import SwiftUI

struct PreviewConstants {
    static let mockBarUUID = "bar-001"
    static let mockBarName = "The Bar"
    static let mockBarNameJapanese = "ザ・バー"
    
    static let mockLatitude = 35.6656
    static let mockLongitude = 139.7360
    
    static let mockImageURL = "https://via.placeholder.com/200"
}

func makeMockBar(
    context: NSManagedObjectContext,
    uuid: String = "bar-001",
    name: String = "Test Bar",
    nameJapanese: String = "テストバー",
    latitude: Double = 35.6656,
    longitude: Double = 139.7360,
    visited: Bool = false,
    photoURLs: [String] = [],
    tags: [String] = []
) -> Bar {
    let bar = Bar(context: context)
    bar.uuid = uuid
    bar.name = name
    bar.nameJapanese = nameJapanese
    bar.latitude = latitude
    bar.longitude = longitude
    bar.visited = visited
    bar.photoURLs = photoURLs
    bar.tags = tags
    if visited {
        bar.visitedDate = Date()
    }
    return bar
}

func makeMockBarInfo(
    id: String = "bar-001",
    detailedDescription: String = "A great bar in Golden Gai",
    features: [String] = ["Intimate", "Cozy"],
    specialties: [String] = ["Sake", "Whisky"],
    capacity: Int? = 5
) -> BarInfo {
    return BarInfo(
        id: id,
        detailedDescription: detailedDescription,
        history: "Established in 1985",
        specialties: specialties,
        priceRange: "¥1,000 - ¥3,000",
        openingHours: "6:00 PM - 12:00 AM",
        capacity: capacity,
        owner: "Owner San",
        yearEstablished: 1985,
        features: features,
        comments: []
    )
}

func makePreviewServiceContainer() -> ServiceContainer {
    let mockBarRepository = MockBarRepository()
    mockBarRepository.mockBars = Bar.mockBars
    
    return ServiceContainer(
        barRepository: mockBarRepository,
        cloudRepository: MockCloudRepository(),
        imageRepository: MockImageRepository(),
        preferencesRepository: MockPreferencesRepository()
    )
}

#if DEBUG
extension BarDetailViewModel {
    static var preview: BarDetailViewModel {
        let context = PersistenceController.preview.container.viewContext
        let bar = makeMockBar(context: context, visited: true)
        let vm = BarDetailViewModel(bar: bar)
        vm.barInfo = makeMockBarInfo()
        return vm
    }
}

extension BarListViewModel {
    static var preview: BarListViewModel {
        let vm = BarListViewModel()
        vm.bars = Bar.mockBars
        vm.filteredBars = vm.bars
        return vm
    }
}

extension MapViewModel {
    static var preview: MapViewModel {
        let vm = MapViewModel()
        vm.bars = Bar.mockBars
        vm.visibleBars = vm.bars
        return vm
    }
}

extension SettingsViewModel {
    static var preview: SettingsViewModel {
        let vm = SettingsViewModel()
        vm.isLoggedIn = true
        vm.showEnglish = true
        vm.lastSyncDate = Date(timeIntervalSinceNow: -3600)
        return vm
    }
}
#endif
