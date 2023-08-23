//
//  UserManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import Firebase
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    private var user: ChatUser?
    
    static private var userKey: String { "k_chat_user" }
    static private var appThemeKey: String { "k_app_theme" }
    static private var stickerPacksKey: String { "k_sticker_packs" }
}

extension UserManager {
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    var currentUserID: UserID? {
        return currentUser?.uid
    }
}

extension UserManager {
    func getChatUser() -> ChatUser? {
        if let data = UserDefaults.standard.object(forKey: UserManager.userKey) as? Data,
           let user = try? JSONDecoder().decode(ChatUser.self, from: data) {
             return user
        }
        return nil
    }
    func setChatUser(_ user: ChatUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: UserManager.userKey)
        }
    }
    func getAppTheme() -> AppTheme {
        if let data = UserDefaults.standard.object(forKey: UserManager.appThemeKey) as? Data,
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
             return theme
        }
        return AppTheme.mikanTheme
    }
    func setAppTheme(_ theme: AppTheme) {
        if let encoded = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(encoded, forKey: UserManager.appThemeKey)
        }
    }
    func removeChatUser() {
        UserDefaults.standard.removeObject(forKey: UserManager.userKey)
    }
}


// MARK: - Stickers
extension UserManager {
    func getStickerPacks() -> [StickerPack] {
        if let data = UserDefaults.standard.object(forKey: UserManager.stickerPacksKey) as? Data,
           let packs = try? JSONDecoder().decode([StickerPack].self, from: data) {
            return packs
        }
        return []
    }
    func setStickerPacks(_ packs: [StickerPack]) {
        if let encoded = try? JSONEncoder().encode(packs) {
            UserDefaults.standard.set(encoded, forKey: UserManager.stickerPacksKey)
        }
    }
}

extension Notification.Name {
    static let didChangeAppTheme = Notification.Name("didChangeAppTheme")
}
