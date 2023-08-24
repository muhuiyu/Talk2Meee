//
//  ChatUser.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift

typealias UserID = String

struct ChatUser: Codable {
    let id: String
    let name: String
    let email: String
    let photoURL: String
    var stickerPacks: [StickerPackID]
}

extension ChatUser {
    private struct ChatUserData: Codable {
        let name: String
        let email: String
        let photoURL: String
        let stickerPacks: [StickerPackID]
    }
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: ChatUserData.self)
        name = data.name
        email = data.email
        photoURL = data.photoURL
        stickerPacks = data.stickerPacks
    }
}

// MARK: - Persistable
extension ChatUser: Persistable {
    init(managedObject: UserObject) {
        id = managedObject.id
        name = managedObject.name
        email = managedObject.email
        photoURL = managedObject.photoURL
        stickerPacks = managedObject.stickerPacks
    }
    func managedObject() -> UserObject {
        return UserObject(id: id, name: name, email: email, photoURL: photoURL)
    }
}
