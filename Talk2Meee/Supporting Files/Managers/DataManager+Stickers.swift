//
//  DataManager+Stickers.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// MARK: - Stickers
extension DatabaseManager {
    func fetchStickers(for packIDs: [StickerPackID], isForCurrentUser: Bool = false) async {
        let group = DispatchGroup()
        var packs = [StickerPack]()
        for packID in packIDs {
            group.enter()
            if let pack = await fetchStickers(for: packID) {
                packs.append(pack)
            }
            group.leave()
        }
        group.notify(queue: .main) {
            print("Finished all requests.")
            CacheManager.shared.addStickerPackCache(for: packs) // save to cache
            if isForCurrentUser {
                UserManager.shared.setStickerPacks(packs)   // save to user default
            }
        }
    }
    func fetchStickers(for packID: StickerPackID) async -> StickerPack? {
        do {
            let snapshot = try await stickersCollectionRef.document(packID).getDocument()
            guard snapshot.exists else { return nil }
            return try StickerPack(snapshot: snapshot)
        } catch {
            print("Failed fetchStickers():", error.localizedDescription)
            return nil
        }
    }
}
