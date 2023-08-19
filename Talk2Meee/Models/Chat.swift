//
//  Chat.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift


typealias ChatID = String

struct Chat: Codable {
    let id: ChatID
    let title: String?
    let createdTime: Date
    let imageStoragePath: String?
    let members: [UserID]
    let lastMessage: ChatMessagePreview?
    
    init(id: ChatID, title: String? = nil, createdTime: Date, imageStoragePath: String? = nil, members: [UserID], lastMessage: ChatMessagePreview? = nil) {
        self.id = id
        self.title = title
        self.createdTime = createdTime
        self.imageStoragePath = imageStoragePath
        self.members = members
        self.lastMessage = lastMessage
    }
}

struct ChatMessagePreview: Codable {
    let id: MessageID
    let senderID: UserID
    let preview: String
    
    func toFirebaseData() -> [String: String] {
        return [
            "id": id, "senderID": senderID, "preview": preview
        ]
    }
}

extension Chat {
    private struct ChatData: Codable {
        let title: String?
        let createdTime: Date
        let imageStoragePath: String?
        let members: [UserID]
        let lastMessage: ChatMessagePreview?
    }
    
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: ChatData.self)
        title = data.title
        createdTime = data.createdTime
        imageStoragePath = data.imageStoragePath ?? ""
        members = data.members
        lastMessage = data.lastMessage
    }
    
    func toFirebaseData() -> [String: Any] {
        return [
            "members": members.sorted(),
            "createdTime": Timestamp(date: createdTime),
            "imageStoragePath": imageStoragePath,
            "title": title,
            "lastMessage": lastMessage?.toFirebaseData()
        ]
    }
    
    var isSingleChat: Bool {
        return members.count == 2
    }
}
