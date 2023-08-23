//
//  ManageStickerCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import UIKit
import Kingfisher

protocol ManageStickerCellDelegate: AnyObject {
    func manageStickerCellDidTapAdd(_ cell: ManageStickerCell)
}

class ManageStickerCell: UITableViewCell, BaseCell {
    static var reuseID: String { return NSStringFromClass(ManageStickerCell.self) }
    
    private let nameLabel = UILabel()
    private let previewStackView = UIStackView()
    private let addButton = UIButton()
    
    weak var delegate: ManageStickerCellDelegate?
    
    var stickerPack: StickerPack? {
        didSet {
            configureData()
        }
    }

    var tab: ManageStickerPackViewModel.ManageStickerPackTab = .allPacks {
        didSet {
            addButton.isHidden = tab == .myPacks
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Handlers
extension ManageStickerCell {
    @objc
    private func didTapAdd() {
        delegate?.manageStickerCellDidTapAdd(self)
        DispatchQueue.main.async { [weak self] in
            self?.addButton.setImage(UIImage(systemName: Icons.checkmark), for: .normal)
            self?.addButton.tintColor = .secondaryLabel
            self?.addButton.isEnabled = false
        }
    }
}

// MARK: - View Config
extension ManageStickerCell {
    private func configureData() {
        guard let user = UserManager.shared.getChatUser(), let stickerPack = stickerPack else { return }
        
        let hasStickerPack = user.stickerPacks.contains(stickerPack.id)
        addButton.setImage(UIImage(systemName: hasStickerPack ? Icons.checkmark : Icons.plusCircle), for: .normal)
        addButton.tintColor = hasStickerPack ? .secondaryLabel : .tintColor
        addButton.isEnabled = !hasStickerPack
        
        nameLabel.text = stickerPack.name
        previewStackView.removeAllArrangedSubviews()
        let numberOfPreviewStickers = stickerPack.numberOfStickers < 5 ? stickerPack.numberOfStickers : 5
        let placeholder = UIImage(systemName: Icons.square)
        for (index, sticker) in stickerPack.getStickers().enumerated() {
            if index >= numberOfPreviewStickers { return }
            let imageView = UIImageView()
            imageView.kf.setImage(with: URL(string: sticker.getImageURL()), placeholder: placeholder)
            imageView.contentMode = .scaleAspectFit
            imageView.snp.remakeConstraints { make in
                make.size.equalTo(48)
            }
            previewStackView.addArrangedSubview(imageView)
        }
    }
    private func configureViews() {
        nameLabel.font = .smallMedium
        nameLabel.textAlignment = .left
        nameLabel.textColor = .label
        contentView.addSubview(nameLabel)
        
        previewStackView.axis = .horizontal
        previewStackView.spacing = Constants.Spacing.trivial
        previewStackView.alignment = .leading
        contentView.addSubview(previewStackView)
        
        addButton.setImage(UIImage(systemName: Icons.plusCircle), for: .normal)
        addButton.tintColor = .systemBlue
        addButton.sizeToFit()
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        contentView.addSubview(addButton)
    }
    private func configureConstraints() {
        nameLabel.snp.remakeConstraints { make in
            make.top.leading.equalTo(contentView.layoutMarginsGuide)
            make.trailing.lessThanOrEqualTo(addButton.snp.leading)
        }
        previewStackView.snp.remakeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Constants.Spacing.slight)
            make.bottom.equalTo(contentView.layoutMarginsGuide)
            make.leading.trailing.equalTo(nameLabel)
        }
        addButton.snp.remakeConstraints { make in
            make.trailing.equalTo(contentView.layoutMarginsGuide)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
    }
}

