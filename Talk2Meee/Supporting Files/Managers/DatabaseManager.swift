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
    
    // MARK: - Query anchor
    private var queryChatMessageDocumentAnchor = [ChatID: QueryChatMessageAnchor]()
    
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
            let document = try await chatsCollectionRef.addDocument(data: Chat.getCreateChatFirebaseData(for: memberIDs))
            let chat = Chat(id: document.documentID, createdTime: createdTime, members: memberIDs.sorted())
            self.updateChatCache(for: [chat])
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
        // TODO: - add pagings and certain time?
        do {
            let snapshot = try await chatsCollectionRef.document(chatID).collection("messages").getDocuments()
            let messages = snapshot.documents.compactMap({ try? ChatMessage(snapshot: $0) })
            self.updateMessageCache(for: messages)
            return .success(messages)
        } catch {
            return .failure(error)
        }
    }
    
    private var numberOfMessagesPerFetchRequest: Int { return 5 }
    
    /// Fetches and returns all messages for current chat
    func listenForMessages(for chatID: ChatID) {
        let reference = chatsCollectionRef.document(chatID).collection("messages")
        
        // single query to get startAt snapshot
        reference.order(by: "sentTime", descending: false).limit(to: numberOfMessagesPerFetchRequest).getDocuments { snapshot, error in
            // save startAt snapshot
            if let startAt = snapshot?.documents.last {
                // create listener using startAt snapshot (starting boundary)
                let listener = reference.order(by: "sentTime").start(atDocument: startAt).addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error", error)
                        return
                    }
                    guard let snapshot = snapshot else { return }
                    // append new messages to message array
                    let messages = snapshot.documents.compactMap({ try? ChatMessage(snapshot: $0) })
                    self.updateMessageCache(for: messages)
                }
                // add listener to list
                self.createAnchor(for: chatID, startAt: startAt, listener: listener)
            }
        }
    }
    
    func fetchMoreMessages(for chatID: ChatID) {
        let reference = chatsCollectionRef.document(chatID).collection("messages")
        // single query to get new startAt snapshot
        if let startAt = queryChatMessageDocumentAnchor[chatID]?.startAt {
            reference.order(by: "sentTime").start(atDocument: startAt).limit(to: numberOfMessagesPerFetchRequest).getDocuments { snapshot, error in
                if let newStartAt = snapshot?.documents.last {
                    // previous starting boundary becomes new ending boundary
                    // create another listener using new boundaries
                    let listener = reference.order(by: "sentTime").start(atDocument: newStartAt).end(atDocument: startAt).addSnapshotListener { snapshot, error in
                        if let error = error {
                            print("Error", error)
                            return
                        }
                        guard let snapshot = snapshot else { return }
                        // append new messages to message array
                        let messages = snapshot.documents.compactMap({ try? ChatMessage(snapshot: $0) })
                        self.updateMessageCache(for: messages)
                    }
                    // add listener to list
                    self.updateQueryChatMessageAnchor(for: chatID, startAt: newStartAt, endAt: startAt, newListener: listener)
                }
            }
        }
    }
    func detachListeners(for chatID: ChatID) {
        queryChatMessageDocumentAnchor[chatID]?.listeners.removeAll()
    }
}

// MARK: - Sending messages
extension DatabaseManager {
    /// Creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserID: UserID, firstMessage: ChatMessageContent) {
        
    }
    public func sendMessage(_ message: ChatMessage) async -> VoidResult {
        do {
            let data = message.toFirebaseMessage
            print("data", data)
            let reference = try await chatsCollectionRef.document(message.chatID).collection("messages").addDocument(data: data)
            let previewMessage = ChatMessagePreview(id: reference.documentID, senderID: message.sender, preview: message.generateMessagePreview())
            try await chatsCollectionRef.document(message.chatID).setData([
                "lastMessage": previewMessage.toFirebaseData()
            ], merge: true)
            return .success
        } catch {
            print("Failed sendMessage():", error.localizedDescription)
            return .failure(error)
        }
    }
}

// MARK: - QueryChatMessageAnchor
extension DatabaseManager {
    private func createAnchor(for chatID: ChatID, startAt: QueryDocumentSnapshot, listener: ListenerRegistration) {
        queryChatMessageDocumentAnchor[chatID] = QueryChatMessageAnchor(startAt: startAt, listeners: [ listener ])
    }
    private func updateQueryChatMessageAnchor(for chatID: ChatID, startAt: QueryDocumentSnapshot, endAt: QueryDocumentSnapshot, newListener: ListenerRegistration) {
        if let _ = queryChatMessageDocumentAnchor[chatID] {
            queryChatMessageDocumentAnchor[chatID]?.startAt = startAt
            queryChatMessageDocumentAnchor[chatID]?.endAt = endAt
            queryChatMessageDocumentAnchor[chatID]?.listeners.append(newListener)
        }
    }
}
private struct QueryChatMessageAnchor {
    var startAt: QueryDocumentSnapshot
    var endAt: QueryDocumentSnapshot? = nil
    var listeners: [ListenerRegistration]
}

