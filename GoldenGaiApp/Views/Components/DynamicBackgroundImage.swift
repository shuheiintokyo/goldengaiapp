import SwiftUI

struct DynamicBackgroundImage: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

#Preview {
    DynamicBackgroundImage(imageName: "ContentBackground")
}
