import SwiftUI

struct AppInfoSection: View {
    var body: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text("2.0.0")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text("1")
                    .foregroundColor(.secondary)
            }
        }
    }
}
