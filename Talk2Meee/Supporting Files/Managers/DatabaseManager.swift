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
    
    weak var appCoordinator: AppCoordinator?
    
    // MARK: - Cache
    internal var users = [UserID: ChatUser]()
    internal var chats = [ChatID: Chat]()
    internal var messages = [ChatID: [ChatMessage]]()
    internal var stickerPacks = [StickerPackID: StickerPack]()
    
    // MARK: - References
    internal let usersCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    internal let friendsCollectionRef: CollectionReference = Firestore.firestore().collection("friends")
    internal let chatsCollectionRef: CollectionReference = Firestore.firestore().collection("chats")
    internal let stickersCollectionRef: CollectionReference = Firestore.firestore().collection("stickers")
    
    enum DatabaseManagerError: Error {
        case notLoggedIn
        case emptySnapshot
        case failedCreateChat
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
            self.appCoordinator?.cacheManager.saveChats(chats)
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
        //
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
            return .success(chat)
            
        } catch {
            print("Error in fetchChat():", error.localizedDescription)
            return .failure(error)
        }
    }
    /// Creates and returns new chat with given members
    private func createChat(for memberIDs: [UserID]) async -> Chat? {
        do {
            let createdTime = Date.now
            let document = try await chatsCollectionRef.addDocument(data: [
                Field.members: memberIDs.sorted(),
                "createdTime": Timestamp(date: createdTime),
                "imageStoragePath": nil,
                "title": nil,
                "lastMessage": nil
            ])
            let chat = Chat(id: document.documentID, createdTime: createdTime, members: memberIDs.sorted())
            return chat
        } catch {
            print("Error in createChat():", error.localizedDescription)
            return nil
        }
    }
    private func saveChats(_ updatedChats: [Chat]) {
        // TODO: -
    }
}

// MARK: - Messages
extension DatabaseManager {
    /// Gets all messages for a given chat
    func fetchMessages(for chatID: ChatID) async -> Result<[ChatMessage], Error> {
        // TODO: - add pagings and certain time
        
        do {
            let snapshot = try await chatsCollectionRef.document(chatID).collection("messages").getDocuments()
            let messages = snapshot.documents.compactMap({ try? ChatMessage(snapshot: $0) })
            return .success(messages)
        } catch {
            return .failure(error)
        }
    }
    
    func listenForMessages(for chatID: ChatID, completion: @escaping ((Result<[ChatMessage], Error>) -> Void)) {
        chatsCollectionRef.document(chatID).collection("messages").order(by: "sentTime", descending: false).addSnapshotListener({ snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let snapshot = snapshot else {
                return completion(.failure(DatabaseManagerError.emptySnapshot))
            }
            let messages = snapshot.documents.compactMap({ try? ChatMessage(snapshot: $0) })
            return completion(.success(messages))
        })
    }
}

// MARK: - Sending messages
extension DatabaseManager {
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserID: UserID, firstMessage: ChatMessageContent) {
        
    }
    public func sendMessage(to chatID: ChatID, _ message: ChatMessage) async -> VoidResult {
        do {
            let reference = try await chatsCollectionRef.document(chatID).collection("messages").addDocument(data: message.toFirebaseMessage)
            let previewMessage = ChatMessagePreview(id: reference.documentID, senderID: message.sender, preview: message.generateMessagePreview())
            try await chatsCollectionRef.document(chatID).setData([
                "lastMessage": previewMessage.toFirebaseData()
            ], merge: true)
            return .success
        } catch {
            print("Failed sendMessage():", error.localizedDescription)
            return .failure(error)
        }
    }
}
