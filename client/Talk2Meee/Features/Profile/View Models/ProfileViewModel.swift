//
//  ProfileViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift

class ProfileViewModel: Base.ViewModel {
    // should reload header
}

extension ProfileViewModel {
    func logOutUser() {
        appCoordinator?.logOutUser()
    }
}
