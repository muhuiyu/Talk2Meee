//
//  ChatMessageContent.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import MessageKit

protocol ChatMessageContent: Codable {
    func toMessageKind() -> MessageKind
}

struct ChatMessageTextContent: ChatMessageContent, Codable {
    let text: String
    
    func toMessageKind() -> MessageKind {
        return .text(text)
    }
}

struct ChatMessageImageContent: ChatMessageContent, Codable {
    let imageStoragePath: String
    let thumbnailStoragePath: String
    let caption: String?
    let width: Int
    let height: Int
    let format: String      // File format of the original image, e.g. png, jepg, gif.
    
    func toMessageKind() -> MessageKind {
        let placeholderImage = UIImage(systemName: Icons.questionmarkCircle) ?? UIImage()
        return .photo(Media(url: URL(string: thumbnailStoragePath),
                            placeholderImage: placeholderImage,
                            size: CGSize(width: width, height: height)))
    }
}

typealias StickerID = String
typealias StickerPackID = String

struct ChatMessageStickerContent: ChatMessageContent, Codable {
    let id: StickerID
    let packID: StickerPackID
    
    static let size: CGSize = CGSize(width: 96, height: 96)
    
    func toFireStoragePath() -> String {
        return "gs://hey-there-muyuuu.appspot.com/stickers/\(packID)/\(id)"
    }
    
    func toImageURL() -> String {
        return "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/stickers%2F\(packID)%2F\(id)?alt=media&token=41e84e51-2ea4-438c-ad16-fd67270a4eda"
    }
    
    func toMessageKind() -> MessageKind {
        let placeholderImage = UIImage(systemName: Icons.questionmarkCircle) ?? UIImage()
        return .photo(Media(url: URL(string: self.toImageURL()),
                            placeholderImage: placeholderImage,
                            size: ChatMessageStickerContent.size))
    }
    
//    "https://stickershop.line-scdn.net/stickershop/v1/product/1385382/LINEStorePC/main.png"
}

