import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            Form {
                LanguageSettingsSection(viewModel: viewModel)
                    .environmentObject(appState)
                    .environmentObject(viewModel)
                
                BackgroundSettingsSection(viewModel: viewModel)
                    .environmentObject(appState)
                    .environmentObject(viewModel)
                
                DataUpdateSection()
                    .environmentObject(appState)
                
                AppInfoSection()
                
                AccountSection(viewModel: viewModel)
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
