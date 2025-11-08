import SwiftUI

struct BackgroundSettingsSection: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: SettingsViewModel
    
    let backgroundOptions = ["ContentBackground", "Alternative1", "Alternative2"]
    
    var body: some View {
        Section(header: Text("Appearance")) {
            Picker("Content View Background", selection: $appState.contentViewBackground) {
                ForEach(backgroundOptions, id: \.self) { bg in
                    Text(bg).tag(bg)
                }
            }
            .onChange(of: appState.contentViewBackground) { newValue in
                viewModel.updateBackground(newValue, for: "content")
            }
        }
    }
}
