//
//  CacheManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import Foundation
import RealmSwift

class CacheManager {
    internal let realm: Realm

    public convenience init() throws {
        try self.init(realm: Realm())
    }

    internal init(realm: Realm) {
        self.realm = realm
    }
    
    // save messages locally
    private var users = [UserID: ChatUser]()
    private var chats = [ChatID: Chat]()
    private var messages = [ChatID: [ChatMessage]]()
    
    // save stickers
    private var stickerPacks = [StickerPackID: StickerPack]()
}

// MARK: - Setup
extension CacheManager {
    func setup() {
        users = getAllUsers().reduce(into: [UserID: ChatUser](), { $0[$1.id] = $1 })
    }
}

// MARK: - Stickers
extension CacheManager {
    func addStickerPackCache(for packs: [StickerPack]) {
        packs.forEach({ stickerPacks[$0.id] = $0 })
    }
    func getStickerPack(for packID: StickerPackID) -> StickerPack? {
        return stickerPacks[packID]
    }
}

// MARK: - Chats
extension CacheManager {
    func saveChats(_ updatedChats: [Chat]) {
        // TODO: - 
    }
}

// MARK: - Users
extension CacheManager {
    /// Returns all users
    func getAllUsers() -> [ChatUser] {
        return realm.objects(UserObject.self).map({ ChatUser(managedObject: $0) })
    }
    func getUser(for userID: UserID) -> ChatUser? {
        return realm.objects(UserObject.self).first(where: { $0.id == userID }).map({ ChatUser(managedObject: $0) })
    }
    func saveUser(_ updatedUser: ChatUser) {
        if let _ = users[updatedUser.id] {
            updateData(of: updatedUser) { result in
                switch result {
                case .success:
                    print("Updated user", updatedUser.id)
                case .failure(let error):
                    print("Failed updating user", updatedUser.id, "with error", error)
                }
            }
        } else {
            addData(of: updatedUser) { result in
                switch result {
                case .success:
                    print("Updated user", updatedUser.id)
                case .failure(let error):
                    print("Failed updating user", updatedUser.id, "with error", error)
                }
            }
        }
    }
    func saveUsers(_ updatedUsers: [ChatUser]) {
        updatedUsers.forEach({ saveUser($0) })
    }
    private func addData(of user: ChatUser, completion: @escaping (VoidResult) -> Void) {
        do {
            try realm.write({
                let _ = realm.create(UserObject.self, value: user.managedObject())
            })
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    private func updateData(of user: ChatUser, completion: @escaping (VoidResult) -> Void) {
        do {
            try realm.write({
                realm.add(user.managedObject(), update: .modified)
            })
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    private func deleteData(of id: UserID, completion: @escaping (VoidResult) -> Void) {
        // TODO: -
    }
}
