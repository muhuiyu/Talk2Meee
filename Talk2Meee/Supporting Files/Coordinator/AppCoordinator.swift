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
import FirebaseAuth

class AppCoordinator: Coordinator {
    private let window: UIWindow
    private let disposeBag = DisposeBag()

    private(set) var mainTabBarController: MainTabBarController?
    private var loginObserver: NSObjectProtocol?
    private var appThemeObserver: NSObjectProtocol?
    
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
        Task {
            await restoreUserSession()
            await configureDatabase()
            configureSocket()
            DispatchQueue.main.async { [weak self] in
                self?.applyAppTheme()
                self?.configureRootViewController()
                self?.window.overrideUserInterfaceStyle = .light
                self?.window.makeKeyAndVisible()
            }
        }
    }

    private func configureBindings() {
        loginObserver = NotificationCenter.default.addObserver(forName: .didChangeAuthState, object: nil, queue: .main, using: { [weak self] _ in
            self?.configureUserSessionAfterAuthStateChanged()
        })

        appThemeObserver = NotificationCenter.default.addObserver(forName: .didChangeAppTheme, object: nil, queue: .main, using: { [weak self] _ in
            self?.applyAppTheme()
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
    private func configureSocket() {
        SocketChatManger.shared.connect()
    }
    private func restoreUserSession() async {
        guard let currentUserID = UserManager.shared.currentUserID else { return }
        if let user = await DatabaseManager.shared.fetchUser(currentUserID) {
            UserManager.shared.setChatUser(user)
            DatabaseManager.shared.listenForCurrentUser()
        }
    }
    private func configureDatabase() async {
        await DatabaseManager.shared.syncData()
    }
    private func configureUserSessionAfterAuthStateChanged() {
        Task {
            await self.restoreUserSession()
            await self.configureDatabase()
            self.configureSocket()
            self.configureRootViewController()
        }
    }
}

// MARK: - UI Setup
extension AppCoordinator {
    private func setupMainTabBar() {
        mainTabBarController = MainTabBarController()
        mainTabBarController?.appCoordinator = self
    }
    private func configureRootViewController() {
        if let _ = UserManager.shared.currentUser {
            showHome()
        } else {
            showLogin()
        }
    }
    private func applyAppTheme() {
        let appTheme = UserManager.shared.getAppTheme()
        mainTabBarController?.tabBar.standardAppearance = appTheme.tabBarAppearance
        mainTabBarController?.tabBar.scrollEdgeAppearance = appTheme.tabBarAppearance
        mainTabBarController?.configureTabBarItems()
    }
}

// MARK: - Logout
extension AppCoordinator {
    func logOutUser() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(Notification(name: .didChangeAuthState))
            UserManager.shared.removeChatUser()
            DatabaseManager.shared.clearUserData()
        } catch let signOutError as NSError {
            print("Failed to logout", signOutError)
        }
    }
}

extension Notification.Name {
    static let didChangeAuthState = Notification.Name("didChangeAuthState")
}
