//
//  ProfileViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import FirebaseAuth

class ProfileViewModel: Base.ViewModel {
    
}

extension ProfileViewModel {
    func logOutUser() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(Notification(name: .didChangeAuthState))
        } catch let signOutError as NSError {
            print("Failed to logout", signOutError)
        }
    }
}
