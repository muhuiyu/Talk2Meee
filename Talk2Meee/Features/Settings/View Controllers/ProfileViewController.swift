//
//  ProfileViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit

class ProfileViewController: Base.MVVMViewController<ProfileViewModel> {
    
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
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
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


// MARK: - TableView DataSource and Delegate
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Logout"
        cell.textLabel?.textColor = .systemRed
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if (indexPath == IndexPath(row: 0, section: 0)) {
            let alert = UIAlertController(title: "Logout?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { [weak self] _ in
                self?.viewModel.logOutUser()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
}

