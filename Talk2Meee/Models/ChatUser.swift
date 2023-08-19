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
}

extension ChatUser {
    private struct ChatUserData: Codable {
        let name: String
        let email: String
        let photoURL: String
    }
    init(snapshot: DocumentSnapshot) throws {
        id = snapshot.documentID
        let data = try snapshot.data(as: ChatUserData.self)
        name = data.name
        email = data.email
        photoURL = data.photoURL
    }
}
