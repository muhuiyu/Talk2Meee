//
//  UserObject.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import RealmSwift

final class UserObject: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: UserID = ""
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var photoURL: String = ""
    dynamic var stickerPacks: [StickerPackID] = []
    
    convenience init(id: UserID, name: String, email: String, photoURL: String) {
        self.init()
        self.id = id
        self.name = name
        self.email = email
        self.photoURL = photoURL
    }
}

