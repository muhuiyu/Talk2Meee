//
//  CacheManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import Foundation

class CacheManager {
    static let shared = CacheManager()
    
    private var stickerPacks = [StickerPackID: StickerPack]()
    // save messages to realm
    // save stickers
}

extension CacheManager {
    func addStickerPackCache(for packs: [StickerPack]) {
        packs.forEach({ stickerPacks[$0.id] = $0 })
    }
    func getStickerPack(for packID: StickerPackID) -> StickerPack? {
        return stickerPacks[packID]
    }
}
