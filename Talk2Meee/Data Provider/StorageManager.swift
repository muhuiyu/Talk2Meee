//
//  StorageManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
}

extension StorageManager {
    public typealias UploadPictureResult = Result<String, Error>
}

extension StorageManager {
    /*
     /images/yourname-gmail-com_profile_picture.png
     */
    /// Uploads picture to Firebase storage and returns a completion with URL string to download
    public func updateProfilePicture(with data: Data,
                                     filename: String) async -> UploadPictureResult {
        do {
            let path = "images/\(filename)"
            let metadata = try await storage.child(path).putDataAsync(data)
            let downloadURL = try await storage.child(path).downloadURL()
            return .success(downloadURL.absoluteString)
        } catch {
            return .failure(error)
        }
    }
}
