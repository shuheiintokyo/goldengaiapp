import SwiftUI
import Combine

@MainActor
class EventBus: ObservableObject {
    enum Event: Equatable {
        case barVisited(uuid: String)
        case imageUpdated(uuid: String)
        case cloudSynced(count: Int)
        case mapHighlightRequested(uuid: String)
        case tabSwitched(tab: Int)
        case logout
        case backgroundImageChanged(view: String, imageName: String)
    }
    
    @Published var currentEvent: Event?
    
    static let shared = EventBus()
    
    func emit(_ event: Event) {
        DispatchQueue.main.async {
            self.currentEvent = event
        }
    }
}
