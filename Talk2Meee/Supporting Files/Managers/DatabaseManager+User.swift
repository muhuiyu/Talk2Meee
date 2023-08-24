//
//  DatabaseManager+User.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/21/23.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

extension DatabaseManager {
    public func clearUserData() {
        
    }
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
                "photoURL": user.photoURL?.absoluteString ?? "",
                "stickerPacks": []
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
    internal func fetchUser(_ userID: UserID, completion: @escaping (ChatUser?) -> Void) {
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
    internal func fetchUsers(_ userIDs: [UserID], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        for userID in userIDs {
            group.enter()
            fetchUser(userID) { user in
                if let user = user  {
                    self.updateUserCache(for: [user])
                }
                group.leave()
            }
        }
        group.notify(queue: .main) {
            print("Finished all requests.")
            completion()
        }
    }
    internal func fetchUsers(_ userIDs: [UserID]) async {
        do {
            try await withThrowingTaskGroup(of: ChatUser.self, body: { group in
                for userID in userIDs {
                    group.addTask {
                        if let user = await self.fetchUser(userID) { return user }
                        throw DatabaseManagerError.noUser
                    }
                }
                for try await user in group {
                    self.updateUserCache(for: [user])
                }
            })
        } catch {
            
        }
    }
    func getUser(_ userID: UserID) -> ChatUser? {
        // find in cache first
        return getUserFromCache(for: userID)
        // if not, query user
//        return await fetchUser(userID)
    }
    func listenForCurrentUser() {
        guard let currentUserID = UserManager.shared.currentUserID else { return }
        usersCollectionRef.document(currentUserID).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error", error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else { return }
            if let user = try? ChatUser(snapshot: snapshot) {
                self.updateUserCache(for: [ user ])
            }
        }
    }
    func updateCurrentUserData(to data: ChatUser, imageData: Data? = nil) async {
        guard let user = UserManager.shared.getChatUser() else { return }
        
        var photoURL: String? = nil
        
        if let imageData = imageData {
            let fileName = "profile_image_\(user.id).png"
            let result = await StorageManager.shared.updateProfilePicture(with: imageData, filename: fileName)
            switch result {
            case .success(let urlString):
                photoURL = urlString
            case .failure(let error):
                print("message photo upload error: \(error)")
            }
        }
        var updatedData = [String: Any]()
        if data.name != user.name {
            updatedData["name"] = data.name
        }
        if data.stickerPacks != user.stickerPacks {
            updatedData["stickerPacks"] = data.stickerPacks
        }
        if let photoURL = photoURL {
            updatedData["photoURL"] = photoURL
        }
        if !updatedData.isEmpty {
            do {
                try await usersCollectionRef.document(user.id).setData(updatedData, merge: true)
            } catch {
                print("Error", error)
            }
        }
    }
}
