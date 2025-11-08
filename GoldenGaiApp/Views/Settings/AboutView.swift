import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Information")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("GoldenGaiHopper")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConstants.Strings.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Developer")) {
                    HStack {
                        Text("Created by")
                        Spacer()
                        Text(AppConstants.Strings.author)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Discover and explore Tokyo's Golden Gai district through an interactive map and community reviews.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Features")) {
                    FeatureItem(title: "Bar Discovery", description: "Browse bars with detailed information")
                    FeatureItem(title: "Map Integration", description: "View bars on an interactive map")
                    FeatureItem(title: "Photo Sharing", description: "Upload and view photos of bars")
                    FeatureItem(title: "Community Reviews", description: "Read and write comments in multiple languages")
                    FeatureItem(title: "Cloud Sync", description: "Automatic synchronization across devices")
                }
                
                Section(header: Text("Links")) {
                    Link(destination: URL(string: AppConstants.Urls.privacyPolicy) ?? URL(fileURLWithPath: "")) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link(destination: URL(string: AppConstants.Urls.terms) ?? URL(fileURLWithPath: "")) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AboutView()
}
