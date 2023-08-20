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

struct ChatMessageSticker {
    let packID: StickerPackID
    let stickerID: StickerID
    
    func getStorageLocation() -> String {
        return "gs://hey-there-muyuuu.appspot.com/stickers/\(packID)/\(stickerID)"
    }
    
    func getImageURL() -> String {
        return "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/stickers%2F\(packID)%2F\(stickerID)?alt=media&token=\(StorageManager.shared.storageToken)"
    }
}

struct StickerPack: Codable {
    let id: StickerPackID
    let name: String
    let numberOfStickers: Int
    
    func getCoverImageURL() -> String {
        return "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/stickers%2F\(id)%2Fcover.png?alt=media&token=\(StorageManager.shared.storageToken)"
    }
    
    func getCoverImageStorageLocaltion() -> String {
        return "gs://hey-there-muyuuu.appspot.com/stickers/\(id)/cover.png"
    }
    
    var stickerImageURLs: [String] {
        return (1...numberOfStickers).map({ "gs://hey-there-muyuuu.appspot.com/stickers/\(id)/\($0).png" })
    }
    
    func getStickers() -> [ChatMessageSticker] {
        return (1...numberOfStickers).map({ ChatMessageSticker(packID: id, stickerID: "\($0).png") })
    }
    
    private struct StickerPackData: Codable {
        let name: String
        let numberOfStickers: Int
    }
    
    init?(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: StickerPackData.self)
        name = data.name
        numberOfStickers = data.numberOfStickers
    }
}
