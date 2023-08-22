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

/// ChatList
class HomeViewController: Base.MVVMViewController<HomeViewModel> {
    
    // MARK: - Views
    private let refreshControl = UIRefreshControl()
    private let spinner = JGProgressHUD(style: .dark)
    private let searchBar = UISearchBar()
    private let searchController = UISearchController()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        spinner.show(in: view)
        viewModel.listenForAllChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - Handlers
extension HomeViewController {
    @objc
    private func didTapCompose() {
        let viewController = NewConversationViewController(appCoordinator: self.appCoordinator, viewModel: NewConversationViewModel(appCoordinator: self.appCoordinator))
        viewController.delegate = self
        present(viewController.embedInNavgationController(), animated: true)
    }
    @objc
    private func refreshData() {
        viewModel.listenForAllChats()
    }
}

// MARK: - View Config
extension HomeViewController {
    private func configureViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapCompose))
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatPreviewCell.self, forCellReuseIdentifier: ChatPreviewCell.reuseID)
        view.addSubview(tableView)
        
        emptyStateLabel.text = "No converstaions"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.isHidden = true // hide while loading
        emptyStateLabel.font = .body
        
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
        if viewModel.displayedChats.value.isEmpty {
            tableView.isHidden = true
            emptyStateLabel.isHidden = false
        } else {
            tableView.isHidden = false
            emptyStateLabel.isHidden = true
            tableView.reloadData()
        }
        refreshControl.endRefreshing()
    }
    private func configureBindings() {
        viewModel.displayedChats
            .asObservable()
            .subscribe { _ in
                DispatchQueue.main.async { [ weak self] in
                    self?.spinner.dismiss()
                    self?.configureData()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - TableView DataSource and Delegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedChats.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatPreviewCell.reuseID, for: indexPath) as? ChatPreviewCell else { return UITableViewCell() }
        cell.viewModel = ChatViewModel(appCoordinator: self.appCoordinator, chat: viewModel.getChat(at: indexPath))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? ChatPreviewCell, let viewModel = cell.viewModel else { return }
        let viewController = ChatViewController(appCoordinator: self.appCoordinator, viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil, handler: { [weak self] _, _, completion in
            self?.presentDeleteConfirmation(for: indexPath, { hasRemoved in
                if hasRemoved {
                    self?.viewModel.deleteChat(at: indexPath)
                }
                completion(true)
            })
        })
        deleteAction.image = UIImage(systemName: Icons.trash)
        return UISwipeActionsConfiguration(actions: [ deleteAction ])
    }
    func presentDeleteConfirmation(for indexPath: IndexPath, _ completion: @escaping ((Bool) -> Void)) {
        let alert = UIAlertController(title: nil, message: "Remove chat?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(false)
        }))
        present(alert, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.filterChats(for: query)
    }
}

// MARK: - NewConversationViewControllerDelegate
extension HomeViewController: NewConversationViewControllerDelegate {
    func newConversationViewControllerDidSelectUser(_ user: ChatUser) {
        spinner.show(in: view)
        Task {
            guard let chat = await viewModel.getChat(with: user.id) else { return }
            spinner.dismiss()
            let viewController = ChatViewController(appCoordinator: self.appCoordinator, viewModel: ChatViewModel(appCoordinator: self.appCoordinator, chat: chat))
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

