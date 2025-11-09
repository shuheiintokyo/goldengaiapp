import SwiftUI
import Foundation
import Combine
import UIKit

@MainActor
class ImageService: ObservableObject {
    @Published var isUploading = false
    @Published var uploadProgress: Double = 0.0
    
    private let imageRepository: ImageRepository
    private let cloudRepository: CloudRepository
    
    @MainActor
    init(
        imageRepository: ImageRepository = FileSystemImageRepository.shared,
        cloudRepository: CloudRepository = AppwriteCloudRepository.shared
    ) {
        self.imageRepository = imageRepository
        self.cloudRepository = cloudRepository
    }
    
    // MARK: - Load Local Image
    
    func load(for uuid: String) -> UIImage? {
        imageRepository.load(for: uuid)
    }
    
    // MARK: - Save Local Image
    
    func saveLocal(_ image: UIImage, for uuid: String) throws {
        try imageRepository.save(image, for: uuid)
    }
    
    // MARK: - Upload to Cloud
    
    func uploadImage(_ image: UIImage, for uuid: String) async throws -> String {
        print("📸 Starting image upload for bar: \(uuid)")
        isUploading = true
        uploadProgress = 0.0
        defer { isUploading = false }
        
        do {
            // Compress image
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw ImageError.invalidFormat
            }
            
            uploadProgress = 0.3
            print("✅ Image compressed: \(imageData.count / 1024) KB")
            
            // Save locally first
            try saveLocal(image, for: uuid)
            uploadProgress = 0.6
            
            // Upload to cloud
            let imageURL = try await cloudRepository.uploadImage(imageData, for: uuid)
            uploadProgress = 1.0
            
            print("✅ Image uploaded: \(imageURL)")
            return imageURL
        } catch {
            print("❌ Upload failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Download from Cloud
    
    func downloadImage(_ imageURL: String, for uuid: String) async throws {
        print("⬇️ Downloading image for: \(uuid)")
        
        do {
            guard let url = URL(string: imageURL) else {
                throw BarError.invalidData("Invalid image URL")
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw BarError.networkError("Invalid response from server")
            }
            
            guard let image = UIImage(data: data) else {
                throw ImageError.invalidFormat
            }
            
            try saveLocal(image, for: uuid)
            print("✅ Image downloaded and saved: \(uuid)")
        } catch {
            print("❌ Download failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Delete Image
    
    func delete(for uuid: String) throws {
        try imageRepository.delete(for: uuid)
    }
    
    // MARK: - Batch Operations
    
    func downloadMultipleImages(urls: [(url: String, uuid: String)]) async throws {
        print("⬇️ Downloading \(urls.count) images...")
        
        for (index, item) in urls.enumerated() {
            do {
                try await downloadImage(item.url, for: item.uuid)
                uploadProgress = Double(index) / Double(urls.count)
            } catch {
                print("⚠️ Failed to download image for \(item.uuid): \(error.localizedDescription)")
                // Continue with next image
            }
        }
        
        print("✅ Batch download completed")
    }
    
    // MARK: - Image Info
    
    func getLocalImageSize(for uuid: String) -> Int? {
        guard let imageRepository = imageRepository as? FileSystemImageRepository else {
            return nil
        }
        return imageRepository.getImageSize(for: uuid)
    }
    
    func getTotalLocalImagesSize() -> Int {
        guard let imageRepository = imageRepository as? FileSystemImageRepository else {
            return 0
        }
        return imageRepository.getTotalImagesSize()
    }
    
    func getAllLocalImageUUIDs() -> [String] {
        guard let imageRepository = imageRepository as? FileSystemImageRepository else {
            return []
        }
        return imageRepository.getAllImageUUIDs()
    }
    
    // MARK: - Cleanup
    
    func clearLocalImages() throws {
        guard let imageRepository = imageRepository as? FileSystemImageRepository else {
            return
        }
        try imageRepository.clearAllImages()
    }
    
    func clearExpiredImages(olderThan days: Int) throws {
        // Implementation would depend on storing image creation dates
        print("🗑️ Clearing images older than \(days) days")
    }
}
