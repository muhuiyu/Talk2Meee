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
        appCoordinator?.logOutUser()
    }
}
