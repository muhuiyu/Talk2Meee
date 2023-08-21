//
//  DatabaseManager+Cache.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

extension DatabaseManager {
    func syncData() async {
        DispatchQueue.main.async {
            self.appCoordinator?.cacheManager.setup()
        }
        guard let user = UserManager.shared.getChatUser() else { return }
        await DatabaseManager.shared.fetchStickers(for: user.stickerPacks, isForCurrentUser: true)
    }
}
