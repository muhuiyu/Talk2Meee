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

protocol NewConversationViewControllerDelegate: AnyObject {
    func newConversationViewControllerDidSelectUser(_ user: ChatUser)
//    func newConversationViewControllerDidSelectConversation() // for group chat?
}

class NewConversationViewController: Base.MVVMViewController<NewConversationViewModel> {
    
    private let spinner = JGProgressHUD(style: .dark)
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    weak var delegate: NewConversationViewControllerDelegate?
    
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
        
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        emptyStateLabel.isHidden = true
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
    private func configureData() {
        if viewModel.displayedUsers.value.isEmpty {
            tableView.isHidden = true
            emptyStateLabel.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStateLabel.isHidden = true
            tableView.reloadData()
        }
    }
    private func configureBindings() {
        viewModel.displayedUsers
            .asObservable()
            .subscribe { value in
                DispatchQueue.main.async { [weak self] in
                    self?.spinner.dismiss(animated: true)
                    self?.configureData()
                }
            }
            .disposed(by: disposeBag)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        spinner.show(in: view)
        viewModel.searchUsers(query: text)
    }
}

// MARK: - TableView DataSource and Delegate
extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedUsers.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.displayedUsers.value[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        delegate?.newConversationViewControllerDidSelectUser(viewModel.displayedUsers.value[indexPath.row])
        dismiss(animated: true)
    }
    
}

