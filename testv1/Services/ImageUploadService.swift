//
//  ImageUploadService.swift
//  Halfisies
//
//  Handles image uploads to Firebase Storage
//

import Foundation
import SwiftUI
import FirebaseStorage
import UIKit

class ImageUploadService {
    static let shared = ImageUploadService()
    
    private let storage = Storage.storage()
    private let maxImageSize: Int = 2 * 1024 * 1024 // 2MB
    
    private init() {}
    
    // MARK: - Upload Avatar
    
    /// Upload user avatar to Firebase Storage
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - userId: The user's ID for the storage path
    /// - Returns: The download URL of the uploaded image
    func uploadAvatar(image: UIImage, userId: String) async throws -> URL {
        // Compress and resize image
        guard let imageData = compressImage(image, maxSize: maxImageSize) else {
            throw ImageUploadError.compressionFailed
        }
        
        // Create storage reference
        let storageRef = storage.reference()
        let avatarRef = storageRef.child("avatars/\(userId)/profile.jpg")
        
        // Upload metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the image
        do {
            _ = try await avatarRef.putDataAsync(imageData, metadata: metadata)
            
            // Get download URL
            let downloadURL = try await avatarRef.downloadURL()
            
            print("[Halfsies] Avatar uploaded successfully: \(downloadURL)")
            return downloadURL
        } catch {
            print("[Halfsies] Avatar upload failed: \(error)")
            throw ImageUploadError.uploadFailed
        }
    }
    
    /// Delete user avatar from Firebase Storage
    func deleteAvatar(userId: String) async throws {
        let storageRef = storage.reference()
        let avatarRef = storageRef.child("avatars/\(userId)/profile.jpg")
        
        do {
            try await avatarRef.delete()
            print("[Halfsies] Avatar deleted successfully")
        } catch {
            print("[Halfsies] Avatar deletion failed: \(error)")
            // Don't throw if file doesn't exist
        }
    }
    
    // MARK: - Image Compression
    
    private func compressImage(_ image: UIImage, maxSize: Int) -> Data? {
        // First resize if too large
        let maxDimension: CGFloat = 500
        var resizedImage = image
        
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let scale = maxDimension / max(image.size.width, image.size.height)
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
            UIGraphicsEndImageContext()
        }
        
        // Try compression at different qualities
        var compressionQuality: CGFloat = 0.8
        var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        
        while let data = imageData, data.count > maxSize && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        }
        
        return imageData
    }
}

// MARK: - Image Upload Errors
enum ImageUploadError: LocalizedError {
    case compressionFailed
    case uploadFailed
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to process image. Please try a different photo."
        case .uploadFailed:
            return "Failed to upload image. Please check your connection and try again."
        case .invalidImage:
            return "Invalid image format. Please select a different photo."
        }
    }
}

// MARK: - UIImage Extension for SwiftUI
extension UIImage {
    /// Create UIImage from SwiftUI Image (via Data)
    convenience init?(data: Data) {
        self.init(data: data)
    }
}
