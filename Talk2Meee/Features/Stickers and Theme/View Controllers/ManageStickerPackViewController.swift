//
//  ManageStickerPackViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import UIKit
import RxSwift
import RxRelay
import JGProgressHUD

class ManageStickerPackViewController: Base.MVVMViewController<ManageStickerPackViewModel> {
    
    // MARK: - Views
    private let spinner = JGProgressHUD(style: .dark)
    private let segmentControl = UISegmentedControl(items: ["All packs", "My packs"])
    private let tableView = UITableView()
    private let emptyLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        Task {
            self.spinner.show(in: self.view)
            await self.viewModel.fetchStickerPacks()
            self.spinner.dismiss()
        }
    }
}

// MARK: - Handlers
extension ManageStickerPackViewController {
    @objc
    private func didChangeSegmentControl(_ sender: UISegmentedControl) {
        guard let toTab = ManageStickerPackViewModel.Tab(rawValue: sender.selectedSegmentIndex) else { return }
        if viewModel.currentTab.value.rawValue != sender.selectedSegmentIndex {
            viewModel.currentTab.accept(toTab)
        }
    }
}

// MARK: - View Config
extension ManageStickerPackViewController {
    private func configureViews() {
        title = "Stickers"
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        view.addSubview(segmentControl)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ManageStickerCell.self, forCellReuseIdentifier: ManageStickerCell.reuseID)
        view.addSubview(tableView)
        
        emptyLabel.font = .small
        emptyLabel.textColor = UserManager.shared.getAppTheme().colorSkin.secondaryLabelColor
        emptyLabel.textAlignment = .center
        emptyLabel.text = "No sticker pack"
        emptyLabel.isHidden = true
        view.backgroundColor = UserManager.shared.getAppTheme().colorSkin.backgroundColor
        view.addSubview(emptyLabel)
    }
    private func configureConstraints() {
        segmentControl.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide).inset(Constants.Spacing.medium)
            make.centerX.equalToSuperview()
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(Constants.Spacing.trivial)
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    private func configureBindings() {
        viewModel.currentTab
            .asObservable()
            .subscribe { value in
                DispatchQueue.main.async { [weak self] in
                    if value.rawValue != self?.segmentControl.selectedSegmentIndex {
                        self?.segmentControl.selectedSegmentIndex = value.rawValue
                    }
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.displayedPacks
            .asObservable()
            .subscribe { _ in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if self.viewModel.displayedPacks.value.isEmpty {
                        self.tableView.isHidden = true
                        self.emptyLabel.isHidden = false
                    } else {
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                        self.emptyLabel.isHidden = true
                    }
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - TableView DataSource and Delegate
extension ManageStickerPackViewController: UITableViewDataSource, UITableViewDelegate, ManageStickerCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayedPacks.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManageStickerCell.reuseID, for: indexPath) as? ManageStickerCell else { return UITableViewCell() }
        cell.tab = viewModel.currentTab.value
        cell.stickerPack = viewModel.displayedPacks.value[indexPath.row]
        cell.delegate = self
        return cell
    }
    func manageStickerCellDidTapAdd(_ cell: ManageStickerCell, _ stickerPack: StickerPack) {
        viewModel.addStickerPack(for: stickerPack.id)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        let viewController = StickerPackDetailsViewController(appCoordinator: self.appCoordinator)
        viewController.delegate = self
        viewController.stickerPack = viewModel.displayedPacks.value[indexPath.row]
        present(viewController.embedInNavgationController(), animated: true)
    }
}

// MARK: - StickerPackDetailsViewControllerDelegate
extension ManageStickerPackViewController: StickerPackDetailsViewControllerDelegate {
    func stickerPackDetailsViewControllerDidTapRemove(_ viewController: StickerPackDetailsViewController, _ stickerPack: StickerPack) {
        viewModel.removeStickerPack(for: stickerPack.id)
    }
    func stickerPackDetailsViewControllerDidTapAdd(_ viewController: StickerPackDetailsViewController, _ stickerPack: StickerPack) {
        viewModel.addStickerPack(for: stickerPack.id)
    }
}
