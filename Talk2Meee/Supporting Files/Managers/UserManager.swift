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
    static private var appThemeIDKey: String { "k_app_theme_id" }
    static private var stickerPacksKey: String { "k_sticker_packs" }
    static private var fcmTokenKey: String { "k_fcm_token" }
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
        if let themeID = UserDefaults.standard.object(forKey: UserManager.appThemeIDKey) as? String {
            return AppTheme.themes[themeID] ?? AppTheme.defaultTheme
        }
        return AppTheme.mikanTheme
    }
    func setAppTheme(_ themeID: AppThemeID) {
        UserDefaults.standard.set(themeID, forKey: UserManager.appThemeIDKey)
    }
    func removeChatUser() {
        UserDefaults.standard.removeObject(forKey: UserManager.userKey)
    }
    func getStickerPacks() -> [StickerPack] {
        guard let stickerPackIDs = getChatUser()?.stickerPacks else { return [] }
        return stickerPackIDs.compactMap({ DatabaseManager.shared.getStickerPack(for: $0) })
    }
    func getFCMToken() -> String? {
        return UserDefaults.standard.object(forKey: UserManager.fcmTokenKey) as? String
    }
    func setFCMToken(with token: String) {
        UserDefaults.standard.set(token, forKey: UserManager.fcmTokenKey)
    }
}

extension Notification.Name {
    static let didChangeAppTheme = Notification.Name("didChangeAppTheme")
}
