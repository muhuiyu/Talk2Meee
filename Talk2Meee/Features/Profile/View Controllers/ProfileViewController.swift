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
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileViewModel.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileViewModel.sections[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = ProfileViewModel.sections[indexPath.section][indexPath.row]
        
        if item == .profile {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileUserCell.reuseID, for: indexPath) as? ProfileUserCell else { return UITableViewCell() }
            cell.delegate = self
            return cell
        }
        
        if item.isDefaultCell {
            let cell = UITableViewCell()
            cell.imageView?.image = item.image
            cell.textLabel?.text = item.title
            if item == .logOut {
                cell.textLabel?.textColor = .systemRed
            }
            return cell
        }
        
        return UITableViewCell()
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
        let item = ProfileViewModel.sections[indexPath.section][indexPath.row]
        
        if item == .logOut {
            let alert = UIAlertController(title: "Logout?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self] _ in
                self?.viewModel.logOutUser()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
        
        if let viewController = viewModel.getViewController(for: item) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

