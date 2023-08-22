//
//  DatabaseManager+Cache.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import RealmSwift

extension DatabaseManager {
    func syncData() async {
        guard let user = UserManager.shared.getChatUser() else { return }
        await DatabaseManager.shared.fetchStickers(for: user.stickerPacks, isForCurrentUser: true)
        DatabaseManager.shared.listenForAllChats(completion: { _ in
            return
        })
    }
}

// MARK: - Stickers
extension DatabaseManager {
    func getAllPacks() -> [StickerPack] {
        do {
            let realm = try Realm()
            return realm.objects(StickerPackObject.self).map({ StickerPack(managedObject: $0) })
        } catch {
            print("Error", error)
            return []
        }
    }
    func getStickerPack(for packID: StickerPackID) -> StickerPack? {
        do {
            let realm = try Realm()
            return realm.objects(StickerPackObject.self).first(where: { $0.id == packID }).map({ StickerPack(managedObject: $0) })
        } catch {
            print("Error", error)
            return nil
        }
    }
    func updateStickerPackCache(for updatedPacks: [StickerPack]) {
        updatedPacks.forEach({ updateStickerPackCache(for: $0) })
        NotificationCenter.default.post(Notification(name: .didUpdateStickers))
    }
    private func updateStickerPackCache(for updatedPack: StickerPack) {
        do {
            let realm = try Realm()
            
            if let _ = realm.objects(StickerPackObject.self).first(where: { $0.id == updatedPack.id }) {
                updateData(of: updatedPack) { result in
                    self.resultHandler(result)
                }
            } else {
                addData(of: updatedPack, as: StickerPackObject.self) { result in
                    self.resultHandler(result)
                }
            }
        } catch {
            print("Error", error)
        }
    }
}
// MARK: - Chats
extension DatabaseManager {
    func getAllChats() -> [Chat] {
        do {
            let realm = try Realm()
            return realm.objects(ChatObject.self).map({ Chat(managedObject: $0) })
        } catch {
            print("Error", error)
            return []
        }
    }
    func getChat(for id: ChatID) -> Chat? {
        do {
            let realm = try Realm()
            return realm.objects(ChatObject.self).first(where: { $0.id == id }).map({ Chat(managedObject: $0) })
        } catch {
            print("Error", error)
            return nil
        }
    }
    func updateChatCache(for updatedChats: [Chat]) {
        updatedChats.forEach({ updateChatCache(for: $0) })
        NotificationCenter.default.post(Notification(name: .didUpdateChats))
    }
    private func updateChatCache(for updatedChat: Chat) {
        do {
            let realm = try Realm()
            if let _ = realm.objects(ChatObject.self).first(where: { $0.id == updatedChat.id }) {
                updateData(of: updatedChat) { result in
                    self.resultHandler(result)
                }
            } else {
                addData(of: updatedChat, as: ChatObject.self) { result in
                    self.resultHandler(result)
                }
            }
        } catch {
            print("Error", error)
        }
    }
}

// MARK: - Messages
extension DatabaseManager {
    func getMessages(for chatID: ChatID) -> [ChatMessage] {
        do {
            let realm = try Realm()
            return realm.objects(ChatMessageObject.self).filter({ $0.chatID == chatID }).map({ ChatMessage(managedObject: $0) }).sorted(by: { $0.sentTime < $1.sentTime })
        } catch {
            print("Error", error)
            return []
        }
    }
    func updateMessageCache(for updatedMessages: [ChatMessage]) {
        updatedMessages.forEach({ updateMessageCache(for: $0) })
        NotificationCenter.default.post(Notification(name: .didUpdateMessages))
    }
    private func updateMessageCache(for updatedMessage: ChatMessage) {
        do {
            let realm = try Realm()
            if let _ = realm.objects(ChatMessageObject.self).first(where: { $0.id == updatedMessage.id }) {
                updateData(of: updatedMessage) { result in
                    self.resultHandler(result)
                }
            } else {
                addData(of: updatedMessage, as: ChatMessageObject.self) { result in
                    self.resultHandler(result)
                }
            }
            // compare the updatedMessage and update lastMessage in chat
            updateLastMessage(in: updatedMessage.chatID, with: updatedMessage)
        } catch {
            print("Error", error)
        }
    }
    private func updateLastMessage(in chatID: ChatID, with message: ChatMessage) {
        guard let chat = getChat(for: chatID) else { return }
        guard let lastMessage = chat.lastMessage else {
            updateLastMessageInFirebase(for: chatID, lastMessage: message.toMessagePreview())
            return
        }
        if lastMessage.sentTime < message.sentTime {
            updateLastMessageInFirebase(for: chatID, lastMessage: message.toMessagePreview())
        }
    }
}
// MARK: - Users
extension DatabaseManager {
    /// Returns all users
    func getAllUsers() -> [ChatUser] {
        do {
            let realm = try Realm()
            return realm.objects(UserObject.self).map({ ChatUser(managedObject: $0) })
        } catch {
            print("Error", error)
            return []
        }
    }
    func getUserFromCache(for userID: UserID) -> ChatUser? {
        do {
            let realm = try Realm()
            return realm.objects(UserObject.self).first(where: { $0.id == userID }).map({ ChatUser(managedObject: $0) })
        } catch {
            print("Error", error)
            return nil
        }
    }
    private func updateUserCache(for updatedUser: ChatUser) {
        do {
            let realm = try Realm()
            if let _ = realm.objects(UserObject.self).first(where: { $0.id == updatedUser.id }) {
                updateData(of: updatedUser) { result in
                    self.resultHandler(result)
                }
            } else {
                addData(of: updatedUser, as: UserObject.self) { result in
                    self.resultHandler(result)
                }
            }
        } catch {
            print("Error", error)
        }
    }
    func updateUserCache(for updatedUsers: [ChatUser]) {
        updatedUsers.forEach({ updateUserCache(for: $0) })
        NotificationCenter.default.post(Notification(name: .didUpdateUsers))
    }
}

// MARK: - Private methods
extension DatabaseManager {
    private func addData<T: Persistable, TObject: Object>(of data: T, as objectType: TObject.Type, completion: @escaping (VoidResult) -> Void) {
        do {
            let realm = try Realm()
            try realm.write({
                let _ = realm.create(TObject.self, value: data.managedObject())
            })
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    private func updateData<T: Persistable>(of data: T, completion: @escaping (VoidResult) -> Void) {
        do {
            let realm = try Realm()
            try realm.write({
                realm.add(data.managedObject(), update: .modified)
            })
            completion(.success)
        } catch {
            completion(.failure(error))
        }
    }
    private func deleteData(of id: UserID, completion: @escaping (VoidResult) -> Void) {
        // TODO: -
    }
    private func resultHandler(_ result: VoidResult) {
        switch result {
        case .success:
            return
        case .failure(let error):
            print("Failed with error", error)
        }
    }
}

extension Notification.Name {
    static let didUpdateChats = Notification.Name("didUpdateChats")
    static let didUpdateMessages = Notification.Name("didUpdateMessages")
    static let didUpdateUsers = Notification.Name("didUpdateUsers")
    static let didUpdateStickers = Notification.Name("didUpdateStickers")
}
