//
//  DatabaseManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    public func test() {
        
    }
    
    internal let usersCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    internal let friendsCollectionRef: CollectionReference = Firestore.firestore().collection("friends")
    internal let chatsCollectionRef: CollectionReference = Firestore.firestore().collection("chats")
    internal let stickersCollectionRef: CollectionReference = Firestore.firestore().collection("stickers")
    
    // Signal -> when user changes: always have the latest, use firebase to send signal everytime when user changes
    private var fetchedUsers = [UserID: ChatUser]()
    
    enum DatabaseManagerError: Error {
        case notLoggedIn
        case emptySnapshot
        case failedCreateChat
        case noStickers
    }
    
    private struct Field {
        static let userID = "userID"
        static let members = "members"
    }
}

// MARK: - Users
extension DatabaseManager {
    /// Inserts new user to database
    public func insertUser(_ user: User) async {
        do {
            guard let name = user.displayName, let email = user.email else {
                print("cannot find user name and email")
                return
            }
            try await usersCollectionRef.document(user.uid).setData([
                "id": user.uid,
                "name": name,
                "email": email,
                "photoURL": user.photoURL?.absoluteString ?? ""
            ])
        } catch {
            print("Error in insertUser(): ", error)
            return
        }
    }
    public func userExists(with email: String) async -> Bool {
        do {
            let querySnapshot = try await usersCollectionRef.whereField("email", isEqualTo: email)
                .getDocuments()
            return !querySnapshot.documents.isEmpty
        } catch {
            print("Error in userExists(): ", error)
            return false
        }
    }
    public func fetchFriends() async -> [ChatUser] {
        guard let currentUserID = UserManager.shared.currentUserID else { return [] }
        
        do {
            let snapshot = try await friendsCollectionRef.document(currentUserID).getDocument()
            // TODO: - Decode to friends
            return []
        } catch {
            print("Error in fetchFriends():", error)
            return []
        }
    }
    public func fetchAllUsers() async -> Result<[ChatUser], Error> {
        do {
            let snapshot = try await usersCollectionRef.getDocuments()
            let users = snapshot.documentChanges
                .filter({ $0.type == .added })
                .compactMap({ try? ChatUser(snapshot: $0.document) })
            return .success(users)
        } catch {
            print("Error in getAllUsers():", error)
            return .failure(error)
        }
    }
    func fetchUser(_ userID: UserID) async -> ChatUser? {
        do {
            let snapshot = try await usersCollectionRef.document(userID).getDocument()
            guard snapshot.exists else { return nil }
            return try ChatUser(snapshot: snapshot)
        } catch {
            print("Error in fetchUser():", error)
            return nil
        }
    }
    private func fetchUser(_ userID: UserID, completion: @escaping (ChatUser?) -> Void) {
        usersCollectionRef.document(userID).getDocument { snapshot, error in
            if let error = error {
                print("Error in fetchUser():", error)
                return completion(nil)
            }
            guard let snapshot = snapshot, snapshot.exists else {
                return completion(nil)
            }
            do {
                let user = try ChatUser(snapshot: snapshot)
                return completion(user)
            } catch {
                
            }
        }
    }
    private func fetchUsers(_ userIDs: [UserID], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for userID in userIDs {
            group.enter()
            fetchUser(userID) { user in
                if let user = user  {
                    self.fetchedUsers[user.id] = user
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            print("Finished all requests.")
            completion()
        }
    }
    private func fetchUsers(_ userIDs: [UserID]) async {
        let group = DispatchGroup()
        for userID in userIDs {
            group.enter()
            if let user = await fetchUser(userID) {
                fetchedUsers[user.id] = user
            }
            group.leave()
        }
        group.notify(queue: .main) {
            print("Finished all requests.")
        }
    }
    func getUser(_ userID: UserID) -> ChatUser? {
        return fetchedUsers[userID]
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
            if shouldFetchUsers {
                let uniqueUserIDs = Array(Set(chats.flatMap({ $0.members })))
                self.fetchUsers(uniqueUserIDs) {
                    return completion(.success(chats))
                }
            } else {
                return completion(.success(chats))
            }
        }
        
//        do {
//
//
//            let snapshot = try await chatsCollectionRef.whereField(Field.members, arrayContains: currentUserID).getDocuments()
//            let chats = snapshot.documents.compactMap({ try? Chat(snapshot: $0) })
//            if shouldFetchUsers {
//                let uniqueUserIDs = Array(Set(chats.flatMap({ $0.members })))
//                await fetchUsers(uniqueUserIDs)
//            }
//            return .success(chats)
//        } catch {
//            print("Error in fetchChats():", error)
//            return .failure(error)
//        }
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
    public func sendMessage(to chatID: ChatID, _ message: ChatMessage) async -> Result<Void, Error> {
        do {
            let reference = try await chatsCollectionRef.document(chatID).collection("messages").addDocument(data: message.toFirebaseMessage)
            let previewMessage = ChatMessagePreview(id: reference.documentID, senderID: message.sender, preview: message.generateMessagePreview())
            try await chatsCollectionRef.document(chatID).setData([
                "lastMessage": previewMessage.toFirebaseData()
            ], merge: true)
            return .success(())
        } catch {
            print("Failed sendMessage():", error.localizedDescription)
            return .failure(error)
        }
    }
}
