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
    public typealias GetDownloadURLResult = Result<String, Error>
}

extension StorageManager {
    public func getDownloadURLForFile(in chatID: ChatID, _ filename: String) async -> GetDownloadURLResult {
        do {
            let downloadURL = try await storage.child(getChatFilePath(in: chatID, filename)).downloadURL()
            return .success(downloadURL.absoluteString)
        } catch {
            return .failure(error)
        }
    }
    /*
     /profile_pictures/uid_profile_picture.png
     */
    /// Uploads picture to Firebase storage and returns a completion with URL string to download
    public func updateProfilePicture(with data: Data,
                                     filename: String) async -> UploadPictureResult {
        do {
            let path = "profile_pictures/\(filename)"
            _ = try await storage.child(path).putDataAsync(data)
            let downloadURL = try await storage.child(path).downloadURL()
            return .success(downloadURL.absoluteString)
        } catch {
            return .failure(error)
        }
    }
    
    /// Uploads image that will be sent in a chat message
    public func uploadMessagePhoto(in chatID: ChatID,
                                   with data: Data,
                                   _ filename: String) async -> UploadPictureResult {
        do {
            let _ = try await storage.child(getChatFilePath(in: chatID, filename)).putDataAsync(data)
            let downloadURL = try await storage.child(getChatFilePath(in: chatID, filename)).downloadURL()
            return .success(downloadURL.absoluteString)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Private methods
extension StorageManager {
    private func getChatFilePath(in chatID: ChatID, _ filename: String) -> String {
        return "chats/\(chatID)/files/\(filename)"
    }
    private func getStickerPath(for stickerID: StickerID, from stickerPackID: StickerPackID) -> String {
        return "stickers/\(stickerID)/\(stickerPackID)"
    }
}
