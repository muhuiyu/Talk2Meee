//
//  ChatObject.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import RealmSwift

final class ChatObject: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: ChatID = ""
    @objc dynamic var title: String? = nil
    @objc dynamic var createdTime: Date = Date()
    @objc dynamic var imageStoragePath: String? = nil
    dynamic var members: [UserID] = []
    @objc dynamic var lastMessageID: MessageID? = nil
    @objc dynamic var lastMessageSenderID: UserID? = nil
    @objc dynamic var lastMessagePreview: String? = nil

    convenience init(id: ChatID, title: String?, imageStoragePath: String? = nil, members: [UserID], lastMessage: ChatMessagePreview?) {
        self.init()
        self.id = id
        self.title = title
        self.imageStoragePath = imageStoragePath
        self.members = members
        self.lastMessageID = lastMessage?.id
        self.lastMessageSenderID = lastMessage?.senderID
        self.lastMessagePreview = lastMessage?.preview
    }
}
