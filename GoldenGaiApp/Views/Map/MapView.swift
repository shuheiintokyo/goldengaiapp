// MapView.swift - GoldenGaiApp Version (CLEAN & WORKING)
import SwiftUI
import CoreData

struct MapView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bar.locationRow, ascending: true)],
        animation: .default)
    private var bars: FetchedResults<Bar>
    
    @State private var selectedBar: Bar?
    @State private var highlightedBarUUID: String? = nil
    @AppStorage("showEnglish") var showEnglish = false
    
    var initialHighlightUUID: String? = nil
    
    @State private var pendingBarHighlight: String = ""
    @State private var retryCount = 0
    @State private var hasProcessedInitial = false
    
    var body: some View {
        ZStack {
            DynamicBackgroundImage(imageName: "BarMapBackground")
                .ignoresSafeArea()
            
            MapGridView(
                highlightedBarUUID: highlightedBarUUID,
                showEnglish: showEnglish,
                onBarSelected: { bar in
                    selectedBar = bar
                    MapHaptics.selectionHaptic()
                },
                onHighlightChange: { uuid in
                    highlightedBarUUID = uuid
                }
            )
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .navigationDestination(for: Bar.self) { bar in
            BarDetailView(bar: bar)
        }
        .sheet(item: $selectedBar) { bar in
            NavigationStack {
                BarDetailView(bar: bar)
            }
        }
        .onAppear {
            setupTabBar()
            setupNotificationObserver()
            
            if let pendingUUID = UserDefaults.standard.string(forKey: "pendingHighlightUUID"),
               !pendingUUID.isEmpty {
                print("🎯 MapView.onAppear: Found pending highlight UUID in UserDefaults: \(pendingUUID)")
                UserDefaults.standard.removeObject(forKey: "pendingHighlightUUID")
                processHighlightImmediately(pendingUUID)
            }
            else if !hasProcessedInitial {
                hasProcessedInitial = true
                
                if let uuid = initialHighlightUUID, !uuid.isEmpty {
                    print("🎯 MapView.onAppear: Processing initialHighlightUUID: \(uuid)")
                    processHighlightImmediately(uuid)
                } else {
                    print("⏳ MapView.onAppear: No initial UUID provided")
                }
            }
        }
        .onChange(of: bars.count) { newValue in
            if newValue > 0 && !pendingBarHighlight.isEmpty {
                print("📊 Bars loaded (\(newValue)), checking pending highlight: \(pendingBarHighlight)")
                checkForPendingHighlight()
            }
        }
        .background(.clear)
        .presentationBackground(.ultraThinMaterial)
        .onDisappear {
            highlightedBarUUID = nil
            pendingBarHighlight = ""
            retryCount = 0
            hasProcessedInitial = false
        }
    }
    
    // MARK: - Highlight Processing
    
    private func processHighlightImmediately(_ uuid: String) {
        print("⚡ Attempting immediate highlight for UUID: \(uuid)")
        print("   Bars available: \(bars.count)")
        
        if bars.isEmpty {
            print("   ⏳ Bars not loaded yet, will retry...")
            retryCount = 0
            pendingBarHighlight = uuid
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForPendingHighlight()
            }
            return
        }
        
        if let targetBar = bars.first(where: { $0.uuid == uuid }) {
            print("   ✅ Found bar immediately: \(targetBar.name ?? "unknown")")
            
            withAnimation(.easeInOut(duration: 0.3)) {
                self.highlightedBarUUID = uuid
            }
            
            MapHaptics.successHaptic()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                withAnimation {
                    self.highlightedBarUUID = nil
                }
            }
        } else {
            print("   ❌ Bar not found immediately, starting retry logic...")
            retryCount = 0
            pendingBarHighlight = uuid
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForPendingHighlight()
            }
        }
    }
    
    private func checkForPendingHighlight() {
        guard !pendingBarHighlight.isEmpty else { return }
        
        print("🔍 MapView checking for pending highlight: \(pendingBarHighlight)")
        print("   Bars loaded: \(bars.count)")
        print("   Retry count: \(retryCount)")
        
        if bars.isEmpty && retryCount < 5 {
            retryCount += 1
            print("   ⏳ Bars not loaded, retrying in 0.5s... (attempt \(retryCount)/5)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForPendingHighlight()
            }
            return
        }
        
        if let targetBar = bars.first(where: { $0.uuid == pendingBarHighlight }) {
            print("   ✅ Found bar to highlight: \(targetBar.name ?? "unknown")")
            
            highlightedBarUUID = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.highlightedBarUUID = self.pendingBarHighlight
                }
                
                MapHaptics.successHaptic()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.pendingBarHighlight = ""
                    self.retryCount = 0
                }
            }
        } else if retryCount < 5 {
            retryCount += 1
            print("   ⚠️ Bar with UUID \(pendingBarHighlight) not found, retrying... (attempt \(retryCount)/5)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkForPendingHighlight()
            }
        } else {
            print("   ❌ Failed to find bar after 5 attempts, clearing pending highlight")
            MapHaptics.warningHaptic()
            pendingBarHighlight = ""
            retryCount = 0
        }
    }
    
    // MARK: - UI Configuration
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        appearance.backgroundEffect = UIBlurEffect(style: .dark)
        
        let normalColor = UIColor.white.withAlphaComponent(0.6)
        let selectedColor = UIColor.systemBlue
        
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.allSubviews.forEach { view in
                        if let tabBar = view as? UITabBar {
                            tabBar.standardAppearance = appearance
                            tabBar.scrollEdgeAppearance = appearance
                        }
                    }
                }
            }
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("HighlightBar"),
            object: nil,
            queue: .main) { notification in
                if let uuid = notification.userInfo?["barUUID"] as? String,
                   !uuid.isEmpty {
                    print("🎯 MapView received highlight notification for UUID: \(uuid)")
                    self.processHighlightImmediately(uuid)
                }
            }
    }
}

// MARK: - Bar Extension for Map Display

extension Bar {
    var statusEmoji: String {
        visited ? "🟢" : "🔵"
    }
    
    var mapDisplayName: String {
        if let name = name, !name.isEmpty {
            return name
        }
        return "Unknown"
    }
    
    var fullMapDisplay: String {
        let primaryName = mapDisplayName
        if let japaneseName = nameJapanese, !japaneseName.isEmpty {
            return "\(primaryName)\n(\(japaneseName))"
        }
        return primaryName
    }
    
    func distanceFrom(_ bar: Bar) -> Double {
        return 0
    }
}

// MARK: - MapView Statistics Extension

extension Array where Element == Bar {
    var visitedCount: Int {
        filter { $0.visited }.count
    }
    
    var unvisitedCount: Int {
        filter { !$0.visited }.count
    }
    
    var visitedPercentage: Double {
        guard count > 0 else { return 0 }
        return Double(visitedCount) / Double(count) * 100
    }
    
    var groupedByVisitStatus: (visited: [Bar], unvisited: [Bar]) {
        let visited = filter { $0.visited }
        let unvisited = filter { !$0.visited }
        return (visited, unvisited)
    }
    
    func sortedByVisitDate() -> [Bar] {
        sorted { bar1, bar2 in
            let date1 = bar1.visitedDate ?? .distantPast
            let date2 = bar2.visitedDate ?? .distantPast
            return date1 > date2
        }
    }
    
    func search(_ text: String) -> [Bar] {
        guard !text.isEmpty else { return self }
        return filter { bar in
            bar.name?.localizedCaseInsensitiveContains(text) ?? false ||
            bar.nameJapanese?.localizedCaseInsensitiveContains(text) ?? false
        }
    }
}

// MARK: - Map Color Theme

struct MapTheme {
    static let visitedColor = Color.green
    static let unvisitedColor = Color.blue
    static let visitedBackgroundColor = Color.green.opacity(0.15)
    static let unvisitedBackgroundColor = Color.blue.opacity(0.15)
    static let selectionColor = Color.blue
    static let selectionBackgroundColor = Color.blue.opacity(0.08)
    static let highlightColor = Color.orange
    static let highlightBackgroundColor = Color.orange.opacity(0.15)
}

// MARK: - Map Haptics

class MapHaptics {
    static func selectionHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    static func successHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    static func warningHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}

// MARK: - UIView Extension

extension UIView {
    var allSubviews: [UIView] {
        var subviews = [UIView]()
        for subview in self.subviews {
            subviews.append(contentsOf: subview.allSubviews)
            subviews.append(subview)
        }
        return subviews
    }
}
