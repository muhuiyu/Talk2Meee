//
//  HomeViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay
import JGProgressHUD

class HomeViewController: Base.MVVMViewController<HomeViewModel> {
 
    // MARK: - Views
    private let spinner = JGProgressHUD(style: .dark)
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        viewModel.fetchConversations()
    }
}

// MARK: - View Config
extension HomeViewController {
    private func configureViews() {
        // SearchBar and navigationBar
//        searchBar.delegate = self
//        searchBar.placeholder = "タイトルで探す"
//        searchBar.tintColor = UIColor.gray
//        searchBar.keyboardType = UIKeyboardType.default
//        searchBar.returnKeyType = .search
//        searchBar.setImage(UIImage(systemName: Icons.line3HorizontalDecrease), for: .bookmark, state: .normal)
//        navigationItem.titleView = searchBar
        
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.isHidden = true   // hide while loading
        view.addSubview(tableView)
        
        emptyStateLabel.text = "No converstaions"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.isHidden = true // hide while loading
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

// MARK: - TableView DataSource and Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Hello world"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
//        let viewController = ChatViewController(appCoordinator: self.appCoordinator, viewModel: ChatViewModel(appCoordinator: self.appCoordinator))
        let viewController = ChatViewController()
        viewController.title = "Mikan"
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}


// MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
