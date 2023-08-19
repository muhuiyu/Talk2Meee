//
//  ChatMessageContent.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

protocol ChatMessageContent: Codable {
    
}

struct ChatMessageTextContent: ChatMessageContent, Codable {
    let text: String
}

struct ChatMessageImageContent: ChatMessageContent, Codable {
    let imageStoragePath: String
    let thumbnailStoragePath: String
    let caption: String?
    let width: Int
    let height: Int
    let format: String      // File format of the original image, e.g. png, jepg, gif.
}

typealias StickerID = String
typealias StickerPackID = String

struct ChatMessageStickerContent: ChatMessageContent, Codable {
    let id: StickerID
    let packID: StickerPackID
}

