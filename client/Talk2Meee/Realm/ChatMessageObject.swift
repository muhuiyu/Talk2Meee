//
//  ChatMessageObject.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import RealmSwift

final class ChatMessageObject: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: MessageID = ""
    @objc dynamic var chatID: ChatID = ""
    @objc dynamic var sender: UserID = ""
    @objc dynamic var sentTime: Date = Date()
    @objc dynamic var type: ChatMessageType.RawValue = ChatMessageType.text.rawValue
    @objc dynamic var searchableContent: String? = nil
    @objc dynamic var quotedMessageID: MessageID? = nil
    
    // content
    @objc dynamic var textContent: ChatMessageTextContentObject? = nil
    @objc dynamic var imageContent: ChatMessageImageContentObject? = nil
    @objc dynamic var stickerContent: ChatMessageStickerContentObject? = nil
    @objc dynamic var locationContent: ChatMessageLocationContentObject? = nil
    
    convenience init(id: MessageID, chatID: ChatID, sender: UserID, sentTime: Date, type: ChatMessageType, searchableContent: String? = nil, quotedMessageID: MessageID? = nil, textContent: ChatMessageTextContentObject? = nil, imageContent: ChatMessageImageContentObject? = nil, stickerContent: ChatMessageStickerContentObject? = nil, locationContent: ChatMessageLocationContentObject? = nil) {
        self.init()
        self.id = id
        self.chatID = chatID
        self.sender = sender
        self.sentTime = sentTime
        self.type = type.rawValue
        self.searchableContent = searchableContent
        self.quotedMessageID = quotedMessageID
        self.textContent = textContent
        self.imageContent = imageContent
        self.stickerContent = stickerContent
        self.locationContent = locationContent
    }
}

final class ChatMessageTextContentObject: Object {
    @objc dynamic var text: String = ""
    convenience init(content: ChatMessageTextContent) {
        self.init()
        self.text = content.text
    }
}

final class ChatMessageImageContentObject: Object {
    @objc dynamic var imageStoragePath: String = ""
    @objc dynamic var thumbnailStoragePath: String = ""
    @objc dynamic var caption: String? = nil
    @objc dynamic var width: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var format: String = ""
    
    convenience init(content: ChatMessageImageContent) {
        self.init()
        self.imageStoragePath = content.imageStoragePath
        self.thumbnailStoragePath = content.thumbnailStoragePath
        self.caption = content.caption
        self.width = content.width
        self.height = content.height
        self.format = content.format
    }
}

final class ChatMessageStickerContentObject: Object {
    @objc dynamic var id: StickerID = ""
    @objc dynamic var packID: StickerPackID = ""
    convenience init(content: ChatMessageStickerContent) {
        self.init()
        self.id = content.id
        self.packID = content.packID
    }
}

final class ChatMessageLocationContentObject: Object {
    @objc dynamic var longtitude: Double = 0
    @objc dynamic var latitdue: Double = 0
    convenience init(content: ChatMessageLocationContent) {
        self.init()
        self.longtitude = content.longtitude
        self.latitdue = content.latitdue
    }
}
