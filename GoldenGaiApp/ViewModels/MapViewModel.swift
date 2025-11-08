import Foundation
import CoreLocation

@MainActor
class MapViewModel: ObservableObject {
    @Published var bars: [Bar] = []
    @Published var visibleBars: [Bar] = []
    @Published var selectedBar: Bar?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userLocation: CLLocationCoordinate2D?
    
    private let barRepository: BarRepository
    
    init(barRepository: BarRepository = CoreDataBarRepository.shared) {
        self.barRepository = barRepository
    }
    
    func loadBars() {
        isLoading = true
        errorMessage = nil
        
        do {
            bars = barRepository.fetch()
            visibleBars = bars
            print("✅ Loaded \(bars.count) bars for map")
        } catch {
            errorMessage = "Failed to load bars"
            print("❌ Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func filterBarsByDistance(_ distance: Double) {
        guard let userLocation = userLocation else {
            visibleBars = bars
            return
        }
        
        let userLocationStruct = Location(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude
        )
        
        visibleBars = bars.filter { bar in
            let barLocation = Location(latitude: bar.latitude, longitude: bar.longitude)
            let distanceKm = userLocationStruct.distance(to: barLocation)
            return distanceKm <= distance
        }
    }
    
    func selectBar(_ bar: Bar) {
        selectedBar = bar
    }
}
