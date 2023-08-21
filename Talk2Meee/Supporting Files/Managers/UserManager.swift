//
//  UserManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import FirebaseAuth

class UserManager {
    static let shared = UserManager()
    private var user: ChatUser?
    
    static private var userKey: String { "k_chat_user" }
    static private var chatThemeKey: String { "k_chat_theme" }
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
    func getChatTheme() -> ChatTheme {
        if let data = UserDefaults.standard.object(forKey: UserManager.chatThemeKey) as? Data,
           let theme = try? JSONDecoder().decode(ChatTheme.self, from: data) {
             return theme
        }
        return ChatTheme.mikanTheme
    }
    func setChatTheme(_ theme: ChatTheme) {
        if let encoded = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(encoded, forKey: UserManager.chatThemeKey)
        }
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
