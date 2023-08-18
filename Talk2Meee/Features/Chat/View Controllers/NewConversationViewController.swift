//
//  NewConversationViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation

import UIKit
import RxSwift
import RxRelay
import JGProgressHUD

class NewConversationViewController: BaseViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    
}

// MARK: - Handlers
extension NewConversationViewController {
    @objc
    private func didTapCancel() {
        dismiss(animated: true)
    }
}

// MARK: - View Config
extension NewConversationViewController {
    private func configureViews() {
        searchBar.placeholder = "Search for users..."
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapCancel))
        
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        emptyStateLabel.text = "No results"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = .preferredFont(forTextStyle: .body)
        view.addSubview(emptyStateLabel)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        emptyStateLabel.snp.remakeConstraints { make in
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
            make.center.equalToSuperview()
        }
    }
    private func configureBindings() {

    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            
    }
}

// MARK: - TableView DataSource and Delegate
extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

