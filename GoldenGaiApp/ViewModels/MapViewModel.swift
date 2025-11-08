import Foundation

@MainActor
class MapViewModel: ObservableObject {
    @Published var bars: [Bar] = []
    @Published var visibleBars: [Bar] = []
    @Published var selectedBar: Bar?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
    
    func selectBar(_ bar: Bar) {
        selectedBar = bar
    }
}
