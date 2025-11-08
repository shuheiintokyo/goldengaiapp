import SwiftUI

struct LanguageSettingsSection: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text("Language")) {
            Picker("Display Language", selection: $appState.showEnglish) {
                Text("日本語").tag(false)
                Text("English").tag(true)
            }
            .onChange(of: appState.showEnglish) { newValue in
                viewModel.updateLanguage(newValue)
            }
        }
    }
}
