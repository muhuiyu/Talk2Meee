//
//  StickerPackObject.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import RealmSwift
final class StickerPackObject: Object {
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: StickerPackID = ""
    @objc dynamic var name: String = ""
    @objc dynamic var numberOfStickers: Int = 0
    
    convenience init(id: StickerPackID, name: String, numberOfStickers: Int) {
        self.init()
        self.id = id
        self.name = name
        self.numberOfStickers = numberOfStickers
    }
}
