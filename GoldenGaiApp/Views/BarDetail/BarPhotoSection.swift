import SwiftUI
import PhotosUI

struct BarPhotoSection: View {
    let bar: Bar
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isUploading = false
    @State private var uploadError: String?
    
    var onPhotoUpload: (UIImage) async throws -> Void = { _ in }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Photos")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .disabled(isUploading)
            }
            
            if !bar.photoURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(bar.photoURLs, id: \.self) { photoURL in
                            AsyncImage(url: URL(string: photoURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                
                                case .failure:
                                    Image(systemName: "photo")
                                        .frame(width: 100, height: 100)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title)
                        .foregroundColor(.gray)
                    
                    Text("No photos yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            if isUploading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Uploading...")
                        .font(.caption)
                }
            }
            
            if let error = uploadError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                Task {
                    await uploadPhoto(image)
                }
            }
        }
    }
    
    private func uploadPhoto(_ image: UIImage) async {
        isUploading = true
        uploadError = nil
        
        do {
            try await onPhotoUpload(image)
            selectedImage = nil
        } catch {
            uploadError = error.localizedDescription
        }
        
        isUploading = false
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let bar = Bar(context: context)
    bar.name = "Test Bar"
    bar.photoURLs = []
    
    return BarPhotoSection(bar: bar)
        .padding()
}
