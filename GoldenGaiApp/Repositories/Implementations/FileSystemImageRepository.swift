import UIKit
import Foundation

class FileSystemImageRepository: ImageRepository {
    static let shared = FileSystemImageRepository()
    
    private let fileManager = FileManager.default
    private var imagesDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let imagesDir = documentsDirectory.appendingPathComponent("BarImages", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: imagesDir.path) {
            try? fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true, attributes: nil)
        }
        
        return imagesDir
    }
    
    // MARK: - ImageRepository Implementation
    
    func save(_ image: UIImage, for uuid: String) throws {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw ImageError.invalidFormat
        }
        
        // Check file size (max 5MB)
        guard imageData.count <= 5 * 1024 * 1024 else {
            throw ImageError.fileTooLarge
        }
        
        let fileURL = fileURLForUUID(uuid)
        
        do {
            try imageData.write(to: fileURL)
            print("✅ Image saved for bar: \(uuid)")
        } catch {
            print("❌ Failed to save image: \(error.localizedDescription)")
            throw ImageError.storageFailed
        }
    }
    
    func load(for uuid: String) -> UIImage? {
        let fileURL = fileURLForUUID(uuid)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("⚠️ Image not found for bar: \(uuid)")
            return nil
        }
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            if let image = UIImage(data: imageData) {
                print("✅ Image loaded for bar: \(uuid)")
                return image
            } else {
                throw ImageError.invalidFormat
            }
        } catch {
            print("❌ Failed to load image: \(error.localizedDescription)")
            return nil
        }
    }
    
    func delete(for uuid: String) throws {
        let fileURL = fileURLForUUID(uuid)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("⚠️ Image file not found for deletion: \(uuid)")
            return
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("✅ Image deleted for bar: \(uuid)")
        } catch {
            print("❌ Failed to delete image: \(error.localizedDescription)")
            throw ImageError.storageFailed
        }
    }
    
    // MARK: - Helper Methods
    
    private func fileURLForUUID(_ uuid: String) -> URL {
        let sanitizedUUID = uuid.replacingOccurrences(of: "/", with: "_")
        return imagesDirectory.appendingPathComponent("\(sanitizedUUID).jpg")
    }
    
    func getImageSize(for uuid: String) -> Int? {
        let fileURL = fileURLForUUID(uuid)
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let size = attributes[.size] as? Int {
                return size
            }
        } catch {
            print("⚠️ Could not get image size: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func getTotalImagesSize() -> Int {
        do {
            let files = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: [.fileSizeKey])
            return files.reduce(0) { total, url in
                let attributes = try? fileManager.attributesOfItem(atPath: url.path)
                let size = attributes?[.size] as? Int ?? 0
                return total + size
            }
        } catch {
            print("⚠️ Could not calculate total size: \(error.localizedDescription)")
            return 0
        }
    }
    
    func clearAllImages() throws {
        do {
            let files = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try fileManager.removeItem(at: file)
            }
            print("✅ All images cleared")
        } catch {
            print("❌ Failed to clear images: \(error.localizedDescription)")
            throw ImageError.storageFailed
        }
    }
    
    func getAllImageUUIDs() -> [String] {
        do {
            let files = try fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            return files.map { url in
                url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "_", with: "/")
            }
        } catch {
            print("⚠️ Could not get image UUIDs: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - ImageError Extension

enum ImageError: LocalizedError {
    case invalidFormat
    case fileTooLarge
    case storageFailed
    case retrievalFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Image format not supported"
        case .fileTooLarge:
            return "Image file is too large (max 5MB)"
        case .storageFailed:
            return "Failed to save image"
        case .retrievalFailed:
            return "Failed to retrieve image"
        }
    }
}
