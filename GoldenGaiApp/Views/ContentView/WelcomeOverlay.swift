import SwiftUI

struct WelcomeOverlay: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Welcome to GoldenGaiHopper")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Discover and explore the best bars in Tokyo's Golden Gai")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                VStack(spacing: 12) {
                    Feature(icon: "list.bullet", title: "Browse Bars", description: "View all available bars with details")
                    Feature(icon: "map", title: "Map View", description: "See bars on an interactive map")
                    Feature(icon: "camera", title: "Upload Photos", description: "Share your experiences with photos")
                    Feature(icon: "bubble.left", title: "Comments", description: "Read and write reviews")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(role: .cancel) {
                    isPresented = false
                } label: {
                    Text("Skip")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .padding()
        }
    }
}

struct Feature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    @State var isPresented = true
    
    return ZStack {
        Color.white
        
        WelcomeOverlay(isPresented: $isPresented)
            .environmentObject(AppState())
    }
}
