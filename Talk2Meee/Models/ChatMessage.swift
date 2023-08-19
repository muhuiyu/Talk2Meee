//
//  ChatMessage.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

typealias MessageID = String

struct ChatMessage {
    let id: MessageID
    let sender: UserID
    let sentTime: Date
    let type: ChatMessageType
    let content: ChatMessageContent
    let searchableContent: String?
    let quotedMessageID: MessageID?
    
    private struct ChatMessageData: Codable {
        let sender: UserID
        let sentTime: Date
        let type: ChatMessageType
        let content: ChatMessageContent
        let searchableContent: String?
        let quotedMessageID: MessageID?
        
        enum CodingKeys: String, CodingKey {
            case id
            case sender
            case sentTime
            case type
            case content
            case searchableContent
            case quotedMessageID = "quotedMessageId"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            sender = try container.decode(UserID.self, forKey: .sender)
            sentTime = try container.decode(Date.self, forKey: .sentTime)
            
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
            }
            searchableContent = try container.decodeIfPresent(String.self, forKey: .searchableContent)
            quotedMessageID = try container.decodeIfPresent(MessageID.self, forKey: .quotedMessageID)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(sender, forKey: .sender)
            try container.encode(sentTime, forKey: .sentTime)
            try container.encode(type.rawValue, forKey: .type)
            try container.encode(content, forKey: .content)
            try container.encodeIfPresent(searchableContent, forKey: .searchableContent)
            try container.encodeIfPresent(quotedMessageID, forKey: .quotedMessageID)
        }
    }
    
    init?(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: ChatMessageData.self)
        sender = data.sender
        sentTime = data.sentTime
        type = data.type
        content = data.content
        searchableContent = data.searchableContent
        quotedMessageID = data.quotedMessageID
    }
}

enum ChatMessageType: String {
    case text
    case image
    case sticker
}

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
