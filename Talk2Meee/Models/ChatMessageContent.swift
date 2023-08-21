//
//  ChatMessageContent.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import MessageKit
import Kingfisher
import CoreLocation

protocol ChatMessageContent: Codable {
    func toMessageKind() -> MessageKind
    func getSearchableContent() -> String?
}

struct ChatMessageTextContent: ChatMessageContent, Codable {
    let text: String
    
    func toMessageKind() -> MessageKind {
        return .text(text)
    }
    
    func getSearchableContent() -> String? {
        return text
    }
}

extension ChatMessageTextContent {
    init() {
        text = ""
    }
    
    init(content: ChatMessageTextContentObject) {
        text = content.text
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
    
    func getSearchableContent() -> String? {
        return nil
    }
}

extension ChatMessageImageContent {
    init(content: ChatMessageImageContentObject) {
        imageStoragePath = content.imageStoragePath
        thumbnailStoragePath = content.thumbnailStoragePath
        caption = content.caption
        width = content.width
        height = content.height
        format = content.format
    }
}

typealias StickerID = String
typealias StickerPackID = String

struct ChatMessageStickerContent: ChatMessageContent, Codable {
    let id: StickerID
    let packID: StickerPackID
    
    static let size = CGSize(width: 96, height: 96)
    
    func toMessageKind() -> MessageKind {
        let placeholderImage = UIImage(systemName: Icons.questionmarkCircle) ?? UIImage()
        return .photo(Media(url: URL(string: Sticker.getImageURL(for: id, from: packID)),
                            placeholderImage: placeholderImage,
                            size: ChatMessageStickerContent.size))
    }
    
    func getSearchableContent() -> String? {
        return nil
    }
}

extension ChatMessageStickerContent {
    init(content: ChatMessageStickerContentObject) {
        id = content.id
        packID = content.packID
    }
}

struct ChatMessageLocationContent: ChatMessageContent, Codable {
    let longtitude: Double
    let latitdue: Double
    
    static let size = CGSize(width: 200, height: 140)
    
    func toMessageKind() -> MessageKind {
        return .location(Location(location: CLLocation(latitude: latitdue, longitude: longtitude), size: ChatMessageLocationContent.size))
    }
    
    func getSearchableContent() -> String? {
        return nil
    }
}

extension ChatMessageLocationContent {
    init(content: ChatMessageLocationContentObject) {
        longtitude = content.longtitude
        latitdue = content.latitdue
    }
}
