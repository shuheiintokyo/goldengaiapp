import Foundation
import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var contentViewModel = ContentViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background
            DynamicBackgroundImage(imageName: appState.contentViewBackground)
            
            TabView(selection: $selectedTab) {
                // Bar List Tab
                BarListView()
                    .tag(0)
                    .tabItem {
                        Label("Bars", systemImage: "list.bullet")
                    }
                
                // Map Tab
                MapView()
                    .tag(1)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                // Settings Tab
                SettingsView()
                    .tag(2)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .center) {
            if contentViewModel.showWelcome {
                WelcomeOverlay(isPresented: $contentViewModel.showWelcome)
                    .environmentObject(appState)
            }
        }
        .onAppear {
            selectedTab = appState.selectedTab
        }
        .onChange(of: selectedTab) { newTab in
            appState.selectedTab = newTab
        }
    }
}
