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
    
    private let usersCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    private let friendsCollectionRef: CollectionReference = Firestore.firestore().collection("friends")
    private let chatsCollectionRef: CollectionReference = Firestore.firestore().collection("chats")
    
    // Signal -> when user changes: always have the latest, use firebase to send signal everytime when user changes
    private var fetchedUsers = [UserID: ChatUser]()
    
    enum DatabaseManagerError: Error {
        case notLoggedIn
        case emptySnapshot
        case failedCreateChat
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
        guard let currentUserID = Auth.auth().currentUser?.uid else { return [] }
        
        do {
            let snapshot = try await friendsCollectionRef.document(currentUserID).getDocument()
            // TODO: - Decode to friends
            return []
        } catch {
            print("Error in fetchFriends():", error)
            return []
        }
    }
    public func getAllUsers() async -> Result<[ChatUser], Error> {
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
    private func fetchUser(_ userID: UserID) async -> ChatUser? {
        do {
            let snapshot = try await usersCollectionRef.document(userID).getDocument()
            guard snapshot.exists else { return nil }
            return try ChatUser(snapshot: snapshot)
        } catch {
            print("Error in fetchUser():", error)
            return nil
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
}


// MARK: - Chats
extension DatabaseManager {
    public func fetchChats(shouldFetchUsers: Bool = true) async -> Result<[Chat], Error> {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return .failure(DatabaseManagerError.notLoggedIn) }
        do {
            let snapshot = try await chatsCollectionRef.whereField(Field.members, arrayContains: currentUserID).getDocuments()
            let chats = snapshot.documentChanges.filter({ $0.type == .added }).compactMap({ try? Chat(snapshot: $0.document) })
            if shouldFetchUsers {
                let uniqueUserIDs = Array(Set(chats.flatMap({ $0.members })))
                await fetchUsers(uniqueUserIDs)
            }
            return .success(chats)
        } catch {
            print("Error in fetchChats():", error)
            return .failure(error)
        }
    }
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
            guard let chat = snapshot.documentChanges.filter({ $0.type == .added }).compactMap({ try? Chat(snapshot: $0.document) }).first else {
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
    func getUser(_ userID: UserID) -> ChatUser? {
        return fetchedUsers[userID]
    }
}

// MARK: - Messages
extension DatabaseManager {
    func fetchMessages(for chatID: ChatID) async -> Result<[ChatMessage], Error> {
        // TODO: - get certain time only
        
        do {
            let snapshot = try await chatsCollectionRef.document(chatID).collection("messages").getDocuments()
            let messages = snapshot.documentChanges.filter({ $0.type == .added }).compactMap({ try? ChatMessage(snapshot: $0.document) })
            return .success(messages)
        } catch {
            return .failure(error)
        }
    }
}
