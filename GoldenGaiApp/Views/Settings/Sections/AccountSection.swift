import SwiftUI

struct AccountSection: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text("Account")) {
            Button(role: .destructive) {
                viewModel.logout()
                appState.logout()
            } label: {
                Text("Logout")
            }
        }
    }
}
