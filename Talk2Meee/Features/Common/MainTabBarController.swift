//
//  MainTabBarController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    weak var appCoordinator: AppCoordinator?
}

extension MainTabBarController {
    func configureTabBarItems() {
        var mainViewControllers = [UINavigationController]()
        TabBarCategory.allCases.forEach { [weak self] category in
            if let viewController = self?.generateViewController(category) {
                mainViewControllers.append(viewController)
            }
        }
        self.viewControllers = mainViewControllers
    }
    
    private func generateViewController(_ category: TabBarCategory) -> UINavigationController? {
        let viewController = category.getViewController(appCoordinator).embedInNavgationController()
        return viewController
    }
}

enum TabBarCategory: Int, CaseIterable {
    // chats, profile
    case home = 0
    case profile
    
    var title: String {
        switch self {
        case .home: return "Chats"
        case .profile: return "Profile"
        }
    }
    var inactiveImageValue: UIImage? {
        switch self {
        case .home: return UIImage(systemName: Icons.bubbleLeft)
        case .profile: return UIImage(systemName: Icons.gearshape)
        }
    }
    var activeImageValue: UIImage? {
        switch self {
        case .home: return UIImage(systemName: Icons.bubbleLeftFill)
        case .profile: return UIImage(systemName: Icons.gearshapeFill)
        }
    }
    func getViewController(_ appCoordinator: AppCoordinator?) -> BaseViewController {
        let viewController: BaseViewController
        
        switch self {
        case .home:
            viewController = HomeViewController(viewModel: HomeViewModel(appCoordinator: appCoordinator))
        case .profile:
            viewController = ProfileViewController(viewModel: ProfileViewModel(appCoordinator: appCoordinator))
        }
        viewController.title = self.title
        viewController.appCoordinator = appCoordinator
        viewController.tabBarItem = self.tabBarItem
        return viewController
    }
    var tabBarItem: UITabBarItem {
        let item = UITabBarItem(title: self.title, image: self.inactiveImageValue, tag: self.rawValue)
        item.selectedImage = self.activeImageValue
        return item
    }
}
