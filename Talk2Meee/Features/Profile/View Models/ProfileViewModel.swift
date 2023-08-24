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
    
    static let sections: [[ProfileViewControllerItem]] = [
        [.profile],
        [.account, .privacy],
        [.chat, .notification, .stickers, .theme],
        [.logOut]
    ]
}

extension ProfileViewModel {
    func logOutUser() {
        appCoordinator?.logOutUser()
    }
    
    func getViewController(for item: ProfileViewControllerItem) -> UIViewController? {
        switch item {
        case .profile:
            return ProfileDetailsViewController(appCoordinator: self.appCoordinator)
        case .account:
            return BaseViewController(appCoordinator: self.appCoordinator)
        case .privacy:
            return BaseViewController(appCoordinator: self.appCoordinator)
        case .chat:
            return BaseViewController(appCoordinator: self.appCoordinator)
        case .notification:
            return BaseViewController(appCoordinator: self.appCoordinator)
        case .stickers:
            return ManageStickerPackViewController(appCoordinator: self.appCoordinator, viewModel: ManageStickerPackViewModel(appCoordinator: self.appCoordinator))
        case .theme:
            return ManageThemeViewController(appCoordinator: self.appCoordinator, viewModel: ManageThemeViewModel(appCoordinator: self.appCoordinator))
        default:
            return nil
        }
    }
}

enum ProfileViewControllerItem {
    case profile
    case account
    case privacy
    case chat
    case notification
    case stickers
    case theme
    case logOut
    
    var title: String {
        switch self {
        case .account:
            return "Account"
        case .privacy:
            return "Privacy"
        case .chat:
            return "Chat"
        case .notification:
            return "Notification"
        case .stickers:
            return "Stickers"
        case .theme:
            return "Theme"
        case .logOut:
            return "Log out"
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        switch self {
        case .account:
            return UIImage(systemName: Icons.personCropCircle)
        case .privacy:
            return UIImage(systemName: Icons.lock)
        case .chat:
            return UIImage(systemName: Icons.bubbleLeft)
        case .notification:
            return UIImage(systemName: Icons.bell)
        case .stickers:
            return UIImage(systemName: Icons.faceSmiling)
        case .theme:
            return UIImage(systemName: Icons.giftcard)
        default:
            return nil
        }
    }
    
    var isDefaultCell: Bool {
        return self != .profile
    }
}
