import SwiftUI

struct DataUpdateSection: View {
    @EnvironmentObject var appState: AppState
    @StateObject var syncService = SyncService()
    
    var body: some View {
        Section(header: Text("Data Sync")) {
            Button(action: {
                Task {
                    await performSync()
                }
            }) {
                HStack {
                    if syncService.isSyncing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "icloud.and.arrow.down")
                    }
                    Text(syncService.isSyncing ? "Syncing..." : "Sync Now")
                }
            }
            .disabled(syncService.isSyncing)
            
            if let lastSync = appState.lastSyncDate {
                Text("Last synced: \(lastSync.formatted())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let error = syncService.syncError {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private func performSync() async {
        try? await syncService.performFullSync()
        appState.lastSyncDate = syncService.lastSyncDate
    }
}
