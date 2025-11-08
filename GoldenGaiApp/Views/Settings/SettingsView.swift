import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            Form {
                LanguageSettingsSection()
                    .environmentObject(appState)
                    .environmentObject(viewModel)
                
                BackgroundSettingsSection()
                    .environmentObject(appState)
                    .environmentObject(viewModel)
                
                DataUpdateSection()
                    .environmentObject(appState)
                
                AppInfoSection()
                
                AccountSection()
                    .environmentObject(appState)
                    .environmentObject(viewModel)
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
