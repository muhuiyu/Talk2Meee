//
//  ChatMessageSticker.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import FirebaseStorage

struct ChatMessageSticker {
    let packID: StickerPackID
    let stickerID: StickerID
    
    func getImageURL() -> String {
        return "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/stickers%2F\(packID)%2F\(stickerID)?alt=media"
    }
    
    func getStorageLocation() -> String {
        return "gs://hey-there-muyuuu.appspot.com/stickers/\(packID)/\(stickerID)"
    }
    
    static func getImageURL(for stickerID: StickerID, from packID: StickerPackID) -> String {
        return "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/stickers%2F\(packID)%2F\(stickerID)?alt=media"
    }
}

struct StickerPack: Codable {
    static var coverImageName: String { return "cover.png" }
    
    let id: StickerPackID
    let name: String
    let numberOfStickers: Int
    
    func getCoverImageURL() -> String {
        return "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/stickers%2F\(id)%2F\(StickerPack.coverImageName)?alt=media"
    }
    
    func getStickerIDs() -> [StickerID] {
        return (1...numberOfStickers).map({ "\($0).png" })
    }
    
    func getStickers() -> [ChatMessageSticker] {
        return getStickerIDs().compactMap { stickerID in
            return ChatMessageSticker(packID: id, stickerID: stickerID)
        }
    }
    
    private struct StickerPackData: Codable {
        let name: String
        let numberOfStickers: Int
    }
    
    init(id: StickerPackID, name: String, numberOfStickers: Int) {
        self.id = id
        self.name = name
        self.numberOfStickers = numberOfStickers
    }
    
    init?(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: StickerPackData.self)
        name = data.name
        numberOfStickers = data.numberOfStickers
    }
}
