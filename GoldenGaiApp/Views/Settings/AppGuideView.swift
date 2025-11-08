import SwiftUI

struct AppGuideView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Getting Started")) {
                    GuideItem(
                        step: "1",
                        title: "Browse Bars",
                        description: "View all bars in the list and see their details"
                    )
                    
                    GuideItem(
                        step: "2",
                        title: "Mark as Visited",
                        description: "Tap the checkmark to mark a bar as visited"
                    )
                    
                    GuideItem(
                        step: "3",
                        title: "Upload Photos",
                        description: "Add photos to share your experience"
                    )
                }
                
                Section(header: Text("Features")) {
                    FeatureExplanation(
                        icon: "list.bullet",
                        title: "Bar List",
                        description: "View all bars with search and filter options. Sort by name, distance, or visit date."
                    )
                    
                    FeatureExplanation(
                        icon: "map",
                        title: "Map View",
                        description: "See bars on a map. Blue pins are unvisited bars, green pins are visited."
                    )
                    
                    FeatureExplanation(
                        icon: "bubble.left",
                        title: "Comments",
                        description: "Read reviews and write your own comments in English or Japanese."
                    )
                    
                    FeatureExplanation(
                        icon: "camera",
                        title: "Photos",
                        description: "Upload photos from your device and see photos uploaded by others."
                    )
                }
                
                Section(header: Text("Tips & Tricks")) {
                    Text("💡 Search for bars by name in English or Japanese")
                    Text("💡 Use filters to find bars with specific features")
                    Text("💡 Photos are automatically synced to the cloud")
                    Text("💡 Your preferences are saved across sessions")
                }
                
                Section(header: Text("FAQ")) {
                    CollapsibleFAQ()
                }
            }
            .navigationTitle("App Guide")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct GuideItem: View {
    let step: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(step)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct FeatureExplanation: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .fontWeight(.semibold)
                    .font(.subheadline)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CollapsibleFAQ: View {
    @State private var expandedIndex: Int? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(FAQData.faqItems.enumerated()), id: \.offset) { index, item in
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        withAnimation {
                            expandedIndex = expandedIndex == index ? nil : index
                        }
                    }) {
                        HStack {
                            Text(item.question)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(expandedIndex == index ? 90 : 0))
                        }
                    }
                    
                    if expandedIndex == index {
                        Divider()
                        
                        Text(item.answer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                if index < FAQData.faqItems.count - 1 {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    AppGuideView()
}
