//
//  DatabaseManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import RealmSwift
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

public enum VoidResult {
    case success
    case failure(Error)
}

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    // MARK: - References
    internal let usersCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    internal let friendsCollectionRef: CollectionReference = Firestore.firestore().collection("friends")
    internal let chatsCollectionRef: CollectionReference = Firestore.firestore().collection("chats")
    internal let stickersCollectionRef: CollectionReference = Firestore.firestore().collection("stickers")
    
    enum DatabaseManagerError: Error {
        case notLoggedIn
        case emptySnapshot
        case failedCreateChat
        case noUser
        case noStickers
    }
    
    private struct Field {
        static let id = "id"
        static let userID = "userID"
        static let members = "members"
    }
}

// MARK: - Chats
extension DatabaseManager {
    /// Fetches and returns all chat for current user
    public func listenForAllChats(shouldFetchUsers: Bool = true, completion: @escaping (Result<[Chat], Error>) -> ()) {
        guard let currentUserID = UserManager.shared.currentUserID else {
            return completion(.failure(DatabaseManagerError.notLoggedIn))
        }
        chatsCollectionRef.whereField(Field.members, arrayContains: currentUserID).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetchAllChats: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("Error fetching documents")
                return
            }
            let chats = documents.compactMap({ try? Chat(snapshot: $0) })
            self.updateChatCache(for: chats)
            if shouldFetchUsers {
                let uniqueUserIDs = Array(Set(chats.flatMap({ $0.members })))
                self.fetchUsers(uniqueUserIDs) {
                    return completion(.success(chats))
                }
            } else {
                return completion(.success(chats))
            }
        }
    }
    /// Fetches and returns chats with given members
    public func fetchChat(_ memberIDs: [UserID], shouldFetchUsers: Bool = true) async -> Result<Chat, Error> {
        do {
            let snapshot = try await chatsCollectionRef.whereField(Field.members, isEqualTo: memberIDs.sorted()).getDocuments()
            print("snapshot.documentChanges: ", snapshot.documentChanges)
            if snapshot.documentChanges.isEmpty {
                // No existing chat found. Create new chat for members
                guard let chat = await createChat(for: memberIDs) else {
                    return .failure(DatabaseManagerError.failedCreateChat)
                }
                if shouldFetchUsers {
                    await fetchUsers(chat.members)
                }
                return .success(chat)
            }
            guard let chat = snapshot.documents.compactMap({ try? Chat(snapshot: $0) }).first else {
                return .failure(DatabaseManagerError.emptySnapshot)
            }
            if shouldFetchUsers {
                await fetchUsers(chat.members)
            }
            self.updateChatCache(for: [ chat ])
            return .success(chat)
            
        } catch {
            print("Error in fetchChat():", error.localizedDescription)
            return .failure(error)
        }
    }
    /// Creates and returns new chat with given members
    public func createChat(for memberIDs: [UserID]) async -> Chat? {
        do {
            let createdTime = Date.now
            let document = try await chatsCollectionRef.addDocument(data: Chat.getCreateChatFirebaseData(for: memberIDs))
            let chat = Chat(id: document.documentID, createdTime: createdTime, members: memberIDs.sorted())
            self.updateChatCache(for: [ chat ])
            return chat
        } catch {
            print("Error in createChat():", error.localizedDescription)
            return nil
        }
    }
}

// MARK: - Messages
extension DatabaseManager {
    /// sends message
    public func sendMessage(_ message: ChatMessage) {
        SocketChatManger.shared.sendMessage(message)
    }
    /// Receives message
    func receiveMessage(_ data: Any) {
        do {
            guard JSONSerialization.isValidJSONObject(data) else { return }
            let data = try JSONSerialization.data(withJSONObject: data)
            let message = try JSONDecoder().decode(ChatMessage.self, from: data)
            self.updateMessageCache(for: [message])
        } catch {
            print("Failed error", error.localizedDescription)
        }
    }
    func updateLastMessageInFirebase(for chatID: ChatID, lastMessage: ChatMessagePreview) {
        Task {
            try await chatsCollectionRef.document(chatID).setData([ "lastMessage": lastMessage.asDictionary() ], merge: true)
        }
    }
}
