import SwiftUI

struct LoadingView: View {
    let message: String?
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
            
            if let message = message {
                Text(message)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    LoadingView(message: "Loading...")
}
