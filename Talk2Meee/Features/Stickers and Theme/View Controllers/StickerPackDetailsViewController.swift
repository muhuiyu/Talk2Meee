//
//  StickerPackDetailsViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/23/23.
//

import UIKit
import RxSwift
import RxRelay

protocol StickerPackDetailsViewControllerDelegate: AnyObject {
    func stickerPackDetailsViewControllerDidTapRemove(_ viewController: StickerPackDetailsViewController, _ stickerPack: StickerPack)
    func stickerPackDetailsViewControllerDidTapAdd(_ viewController: StickerPackDetailsViewController, _ stickerPack: StickerPack)
}

class StickerPackDetailsViewController: BaseViewController {
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private let actionButton = TextButton()
    
    weak var delegate: StickerPackDetailsViewControllerDelegate?
    
    var stickerPack: StickerPack? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.configureData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}

// MARK: - Handlers
extension StickerPackDetailsViewController {
    @objc
    private func didTapForward() {
//        guard let stickerPack = stickerPack else { return }
        // TODO: - 
    }
    private func didTapActionButton() {
        guard let stickerPack = stickerPack, let user = UserManager.shared.getChatUser() else { return }
        if user.stickerPacks.contains(stickerPack.id) {
            presentDeleteConfirmation { willDelete in
                if willDelete {
                    // dismiss, delete
                    self.delegate?.stickerPackDetailsViewControllerDidTapRemove(self, stickerPack)
                    self.dismiss(animated: true)
                }
            }
        } else {
            // do download
            self.delegate?.stickerPackDetailsViewControllerDidTapAdd(self, stickerPack)
            self.dismiss(animated: true)
        }
        
    }
    private func presentDeleteConfirmation(completion: @escaping ((Bool) -> Void?)) {
        let alert = UIAlertController(title: nil, message: "Remove sticker pack?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
            completion(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(false)
        }))
        present(alert, animated: true)
    }
}

// MARK: - View Config
extension StickerPackDetailsViewController {
    private func configureData() {
        guard let stickerPack = stickerPack, let user = UserManager.shared.getChatUser() else { return }
        title = stickerPack.name
        collectionView.reloadData()
        let hasSticker = user.stickerPacks.contains(stickerPack.id)
        actionButton.buttonColor = hasSticker ? .systemRed : UserManager.shared.getAppTheme().colorSkin.tintColor
        actionButton.text = hasSticker ? "Remove" : "Add"
    }
    private func configureViews() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.initWithThemeColor(image: UIImage(systemName: Icons.arrowshapeTurnUpForward), style: .plain, target: self, action: #selector(didTapForward))
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 84, height: 84)
        layout.scrollDirection = .vertical
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.register(StickerCollectionCell.self, forCellWithReuseIdentifier: StickerCollectionCell.reuseID)
        view.addSubview(collectionView)
        actionButton.textColor = .white
        actionButton.tapHandler = { [weak self] in
            self?.didTapActionButton()
        }
        view.addSubview(actionButton)
    }
    private func configureConstraints() {
        collectionView.snp.remakeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(actionButton.snp.top).offset(-Constants.Spacing.medium)
        }
        actionButton.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.layoutMarginsGuide)
        }
    }
}

// MARK: - Colleciton delegate and dataSource
extension StickerPackDetailsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickerPack?.numberOfStickers ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerCollectionCell.reuseID, for: indexPath) as? StickerCollectionCell,
            let stickerPack = stickerPack
        else { return UICollectionViewCell() }
        cell.urlString = stickerPack.getStickers()[indexPath.item].getImageURL()
        return cell
    }
}
