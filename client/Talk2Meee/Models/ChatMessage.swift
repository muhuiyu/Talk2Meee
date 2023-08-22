//
//  ChatMessage.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import MessageKit
import SocketIO

typealias MessageID = String

struct ChatMessage {
    let id: MessageID
    let chatID: ChatID
    let sender: UserID
    let sentTime: Date
    let type: ChatMessageType
    let content: ChatMessageContent
    let searchableContent: String?
    let quotedMessageID: MessageID?
}


// MARK: - Codable
extension ChatMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case chatID
        case sender
        case sentTime
        case type
        case content
        case searchableContent
        case quotedMessageID = "quotedMessageId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(MessageID.self, forKey: .id)
        chatID = try container.decode(ChatID.self, forKey: .chatID)
        sender = try container.decode(UserID.self, forKey: .sender)
        let sentTimeInterval = try container.decode(TimeInterval.self, forKey: .sentTime)
        sentTime = Date(timeIntervalSince1970: sentTimeInterval)

        let typeRawValue = try container.decode(ChatMessageType.RawValue.self, forKey: .type)
        guard let messageType = ChatMessageType(rawValue: typeRawValue) else {
            fatalError("Invalid mesasge type")
        }
        self.type = messageType
        switch messageType {
        case .text:
            self.content = try container.decode(ChatMessageTextContent.self, forKey: .content)
        case .image:
            self.content = try container.decode(ChatMessageImageContent.self, forKey: .content)
        case .sticker:
            self.content = try container.decode(ChatMessageStickerContent.self, forKey: .content)
        case .location:
            self.content = try container.decode(ChatMessageLocationContent.self, forKey: .content)
        }
        searchableContent = try container.decodeIfPresent(String.self, forKey: .searchableContent)
        quotedMessageID = try container.decodeIfPresent(MessageID.self, forKey: .quotedMessageID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(chatID, forKey: .chatID)
        try container.encode(sender, forKey: .sender)
        try container.encode(sentTime.timeIntervalSince1970, forKey: .sentTime)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(searchableContent, forKey: .searchableContent)
        try container.encodeIfPresent(quotedMessageID, forKey: .quotedMessageID)
    }
}

extension ChatMessage {
    func toMessage() -> Message? {
        guard let senderUser = DatabaseManager.shared.getUser(self.sender) else { return nil }
        let sender = Sender(senderId: senderUser.id, displayName: senderUser.name, photoURL: senderUser.photoURL)
        return Message(sender: sender, messageId: self.id, sentDate: self.sentTime, kind: self.content.toMessageKind())
    }
    
    func toMessagePreview() -> ChatMessagePreview {
        var preview = ""
        switch type {
        case .text:
            if let content = content as? ChatMessageTextContent {
                preview = content.text
            }
        case .image:
            preview = "🏞️[image]"
        case .sticker:
            preview = "🧡[sticker]"
        case .location:
            preview = "📍[location]"
        }
        return ChatMessagePreview(id: id, senderID: sender, preview: preview, sentTime: sentTime)
    }
}

// MARK: - Persistable
extension ChatMessage: Persistable {
    init(managedObject: ChatMessageObject) {
        id = managedObject.id
        chatID = managedObject.chatID
        sender = managedObject.sender
        sentTime = managedObject.sentTime
        searchableContent = managedObject.searchableContent
        quotedMessageID = managedObject.quotedMessageID
        
        guard let messageType = ChatMessageType(rawValue: managedObject.type) else {
            fatalError("Wrong message type")
        }
        type = messageType
        switch messageType {
        case .text:
            guard let textContent = managedObject.textContent else { fatalError("Wrong message type") }
            content = ChatMessageTextContent(content: textContent)
        case .image:
            guard let imageContent = managedObject.imageContent else { fatalError("Wrong message type") }
            content = ChatMessageImageContent(content: imageContent)
        case .sticker:
            guard let stickerContent = managedObject.stickerContent else { fatalError("Wrong message type") }
            content = ChatMessageStickerContent(content: stickerContent)
        case .location:
            guard let locationContent = managedObject.locationContent else { fatalError("Wrong message type") }
            content = ChatMessageLocationContent(content: locationContent)
        }
    }
    func managedObject() -> ChatMessageObject {
        var textContent: ChatMessageTextContentObject?
        var imageContent: ChatMessageImageContentObject?
        var stickerContent: ChatMessageStickerContentObject?
        var locationContent: ChatMessageLocationContentObject?
        
        switch type {
        case .text:
            if let content = content as? ChatMessageTextContent {
                textContent = ChatMessageTextContentObject(content: content)
            }
        case .image:
            if let content = content as? ChatMessageImageContent {
                imageContent = ChatMessageImageContentObject(content: content)
            }
        case .sticker:
            if let content = content as? ChatMessageStickerContent {
                stickerContent = ChatMessageStickerContentObject(content: content)
            }
        case .location:
            if let content = content as? ChatMessageLocationContent {
                locationContent = ChatMessageLocationContentObject(content: content)
            }
        }
        
        return ChatMessageObject(id: id, chatID: chatID, sender: sender, sentTime: sentTime, type: type, searchableContent: searchableContent, quotedMessageID: quotedMessageID, textContent: textContent, imageContent: imageContent, stickerContent: stickerContent, locationContent: locationContent)
    }
}

extension ChatMessage: SocketData {
    func socketRepresentation() throws -> SocketData {
        try self.asDictionary()
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
