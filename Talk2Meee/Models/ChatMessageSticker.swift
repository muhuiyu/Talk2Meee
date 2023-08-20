//
//  ChatMessageSticker.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit

struct ChatMessageSticker {
    let packID: StickerPackID
    let stickerID: StickerID
    let image: UIImage?
    
    func toImageURL() -> String {
        return "gs://hey-there-muyuuu.appspot.com/stickers/\(packID)/\(stickerID)"
    }
}
