//
//  ChatMessage.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import MessageKit
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
    
    init(id: MessageID, sender: UserID, sentTime: Date, type: ChatMessageType, content: ChatMessageContent, searchableContent: String? = nil, quotedMessageID: MessageID? = nil) {
        self.id = id
        self.sender = sender
        self.sentTime = sentTime
        self.type = type
        self.content = content
        self.searchableContent = searchableContent
        self.quotedMessageID = quotedMessageID
    }
}


// MARK: - Codable
extension ChatMessage {
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
        
        init(sender: UserID, sentTime: Date, type: ChatMessageType, content: ChatMessageContent, searchableContent: String?, quotedMessageID: MessageID?) {
            self.sender = sender
            self.sentTime = sentTime
            self.type = type
            self.content = content
            self.searchableContent = searchableContent
            self.quotedMessageID = quotedMessageID
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
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
            try container.encode(sender, forKey: .sender)
            try container.encode(sentTime.timeIntervalSince1970, forKey: .sentTime)
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

extension ChatMessage {
    func toMessage() -> Message? {
        guard let senderUser = DatabaseManager.shared.getUser(self.sender) else { return nil }
        let sender = Sender(senderId: senderUser.id, displayName: senderUser.name, photoURL: senderUser.photoURL)
        return Message(sender: sender, messageId: self.id, sentDate: self.sentTime, kind: self.content.toMessageKind())
    }
    
    private var toChatMessageData: ChatMessageData {
        return ChatMessageData(sender: sender, sentTime: sentTime, type: type, content: content, searchableContent: searchableContent, quotedMessageID: quotedMessageID)
    }
    
    var toFirebaseMessage: [String: Any] {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(self.toChatMessageData)
            if let dataDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
                return dataDictionary
            }
            return [:]
        } catch {
            print("Error:", error)
            fatalError("Failed converting to FirebaseMessage")
        }
    }
    
    func generateMessagePreview() -> String {
        switch type {
        case .text:
            guard let content = content as? ChatMessageTextContent else { return "" }
            return content.text
        case .image:
            return "🏞️[image]"
        case .sticker:
            return "🧡[sticker]"
        case .location:
            return "📍[location]"
        }
    }
}
