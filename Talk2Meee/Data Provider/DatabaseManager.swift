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
}

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
}
