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

class ManageStickerPackViewController: BaseViewController {
    
    // MARK: - Views
    private let spinner = JGProgressHUD(style: .dark)
    private let segmentControl = UISegmentedControl(items: ["All packs", "My packs"])
    private let tableView = UITableView()
    
    private var packs = [StickerPack]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
        
        Task {
            await self.fetchStickerPacks()
        }
    }
}

// MARK: - Handlers
extension ManageStickerPackViewController {
    @objc
    private func didChangeSegmentControl() {
        // TODO: - 
    }
}

// MARK: - View Config
extension ManageStickerPackViewController {
    private func fetchStickerPacks() async {
        self.packs = await DatabaseManager.shared.fetchAllStickerPacks()
    }
    private func configureViews() {
        title = "Stickers"
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(didChangeSegmentControl), for: .valueChanged)
        view.addSubview(segmentControl)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.register(ManageStickerCell.self, forCellReuseIdentifier: ManageStickerCell.reuseID)
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        segmentControl.snp.remakeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide)
            make.centerX.equalToSuperview()
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(Constants.Spacing.trivial)
            make.leading.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureBindings() {
        
    }
}

// MARK: - TableView DataSource and Delegate
extension ManageStickerPackViewController: UITableViewDataSource, UITableViewDelegate, ManageStickerCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManageStickerCell.reuseID, for: indexPath) as? ManageStickerCell else { return UITableViewCell() }
        cell.stickerPack = packs[indexPath.row]
        cell.delegate = self
        return cell
    }
    func manageStickerCellDidTapAdd(_ cell: ManageStickerCell) {
        // TODO: -
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        // TODO: - present sticker details page and add button
    }
}
