//
//  AppCoordinator.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxRelay
import RxSwift
import Firebase

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let disposeBag = DisposeBag()

    private(set) var mainTabBarController: MainTabBarController?
    
    // Login
    private var loginObserver: NSObjectProtocol?

    init?(window: UIWindow?) {
        guard let window = window else { return nil }
        self.window = window
    }

    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func start() {
        configureBindings()
        setupMainTabBar()
        configureDatabase()
        configureRootViewController()
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()
    }

    private func configureBindings() {
        loginObserver = NotificationCenter.default.addObserver(forName: .didChangeAuthState, object: nil, queue: .main, using: { [weak self] _ in
            self?.configureRootViewController()
        })
    }
}

// MARK: - Generic Navigation
extension AppCoordinator {
    enum Destination {
        case home
        case loadingScreen
        case login
    }
    private func changeRootViewController(to viewController: UIViewController?) {
        guard let viewController = viewController else { return }
        window.rootViewController = viewController
    }
    func showHome(forceReplace: Bool = true, animated: Bool = true) {
        changeRootViewController(to: self.mainTabBarController)
    }
    func showLogin(forceReplace: Bool = true, animated: Bool = false) {
        let viewController = LoginViewController(appCoordinator: self, viewModel: LoginViewModel(appCoordinator: self))
        changeRootViewController(to: viewController.embedInNavgationController())
    }
}

// MARK: - Services and managers
extension AppCoordinator {
    private func configureDatabase() {
//        dataProvider.setup()
    }
}

// MARK: - UI Setup
extension AppCoordinator {
    private func setupMainTabBar() {
        mainTabBarController = MainTabBarController()
        mainTabBarController?.appCoordinator = self
        mainTabBarController?.configureTabBarItems()
    }
    private func configureRootViewController() {
        if let _ = UserManager.shared.currentUser {
            showHome()
        } else {
            showLogin()
        }
    }
}


extension Notification.Name {
    static let didChangeAuthState = Notification.Name("didChangeAuthState")
}
