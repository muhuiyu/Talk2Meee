//
//  ProfileViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit

class ProfileViewController: Base.MVVMViewController<ProfileViewModel> {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        
        NotificationCenter.default.addObserver(forName: .didUpdateCurrentUser, object: nil, queue: .main, using: { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [Section.userProfile], with: .none)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - View Config
extension ProfileViewController {
    private func configureViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ProfileUserCell.self, forCellReuseIdentifier: ProfileUserCell.reuseID)
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


// MARK: - TableView DataSource
extension ProfileViewController: UITableViewDataSource {
    private struct Section {
        static let userProfile = IndexPath(row: 0, section: 0)  // 0
        static let account = IndexPath(row: 0, section: 1)      // 1
        static let privacy = IndexPath(row: 1, section: 1)
        static let chat = IndexPath(row: 0, section: 2)         // 2
        static let notification = IndexPath(row: 1, section: 2)
        static let logout = IndexPath(row: 0, section: 3)       // 3
        static let numberOfSections = 4
        static let numberOfRowsInSection: [Int] = [ 1, 2, 2, 1 ]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.numberOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.numberOfRowsInSection[section]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case Section.userProfile:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.reuseID, for: indexPath) as? ProfileUserCell else { return UITableViewCell() }
            cell.delegate = self
            return cell
        case Section.account:
            let cell = UITableViewCell()
            cell.imageView?.image = UIImage(systemName: Icons.personCropCircle)
            cell.textLabel?.text = "Account"
            return cell
        case Section.privacy:
            let cell = UITableViewCell()
            cell.imageView?.image = UIImage(systemName: Icons.lock)
            cell.textLabel?.text = "Privacy"
            return cell
        case Section.chat:
            let cell = UITableViewCell()
            cell.imageView?.image = UIImage(systemName: Icons.bubbleLeft)
            cell.textLabel?.text = "Chat"
            return cell
        case Section.notification:
            let cell = UITableViewCell()
            cell.imageView?.image = UIImage(systemName: Icons.bell)
            cell.textLabel?.text = "Notification"
            return cell
        case Section.logout:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .systemRed
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - TableView delegate
extension ProfileViewController: UITableViewDelegate, ProfileUserCellDelegate {
    func profileUserCellDidTapQRCode(_ cell: ProfileUserCell) {
        let viewController = ProfileQRCodeViewController(appCoordinator: self.appCoordinator)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        switch indexPath {
        case Section.userProfile:
            let viewController = ProfileDetailsViewController(appCoordinator: self.appCoordinator)
            navigationController?.pushViewController(viewController, animated: true)
        case Section.logout:
            let alert = UIAlertController(title: "Logout?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self] _ in
                self?.viewModel.logOutUser()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        default:
            return
        }
    }
}

