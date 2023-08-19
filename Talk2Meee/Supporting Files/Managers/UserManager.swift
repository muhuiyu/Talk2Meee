//
//  UserManager.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import FirebaseAuth

class UserManager {
    
    static let shared = UserManager()

}

extension UserManager {
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var currentUserID: UserID? {
        return currentUser?.uid
    }
}
