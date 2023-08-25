//
//  DatabaseManager+Stickers.swift
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
    func fetchStickers(for packIDs: [StickerPackID]) async {
        do {
            var packs = [StickerPack]()
            try await withThrowingTaskGroup(of: StickerPack.self) { group in
                for packID in packIDs {
                    group.addTask {
                        if let pack = await self.fetchStickerPack(for: packID) { return pack }
                        throw DatabaseManagerError.noStickers
                    }
                }
                for try await pack in group {
                    packs.append(pack)
                }
            }
            self.updateStickerPackCache(for: packs)
        } catch {
            print("Error", error)
        }
    }

    func fetchStickerPack(for packID: StickerPackID) async -> StickerPack? {
        do {
            let snapshot = try await stickersCollectionRef.document(packID).getDocument()
            guard snapshot.exists else { return nil }
            return try StickerPack(snapshot: snapshot)
        } catch {
            print("Failed fetchStickerPack():", error.localizedDescription)
            return nil
        }
    }
    
    func fetchAllStickerPacks() async -> [StickerPack] {
        do {
            let snapshot = try await stickersCollectionRef.getDocuments()
            let packs = try snapshot.documents.compactMap({ try StickerPack(snapshot: $0) })
            self.updateStickerPackCache(for: packs)
            return packs
        } catch {
            print("Failed fetchAllStickerPacks():", error.localizedDescription)
            return []
        }
    }
    
    func fetchAllAppThemes() async -> [AppTheme] {
        // TODO: -
        return Array(AppTheme.themes.values)
    }
}
