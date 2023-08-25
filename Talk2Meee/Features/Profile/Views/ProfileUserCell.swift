//
//  ProfileUserCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/22/23.
//

import UIKit
import Kingfisher

protocol ProfileUserCellDelegate: AnyObject {
    func profileUserCellDidTapQRCode(_ cell: ProfileUserCell)
}

class ProfileUserCell: UITableViewCell, BaseCell {
    
    static var reuseID: String { return NSStringFromClass(ProfileUserCell.self) }
    
    // MARK: - Views
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let qrCodeButton = UIButton()
    
    weak var delegate: ProfileUserCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.roundCorners(corners: .allCorners, radius: 24)
    }
    
}

// MARK: - Handlers
extension ProfileUserCell {
    @objc
    private func didTapQRCode() {
        delegate?.profileUserCellDidTapQRCode(self)
    }
}

// MARK: - View Config
extension ProfileUserCell {
    private func configureViews() {
        guard let user = UserManager.shared.getChatUser() else { return }
        
        let placeholder = UIImage(systemName: Icons.personCropCircle)
        avatarView.contentMode = .scaleAspectFit
        avatarView.clipsToBounds = true
        avatarView.kf.setImage(with: URL(string: user.photoURL), placeholder: placeholder)
        contentView.addSubview(avatarView)
        nameLabel.font = .h3
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .left
        nameLabel.text = user.name
        contentView.addSubview(nameLabel)
        
        qrCodeButton.setImage(UIImage(systemName: Icons.qrcode), for: .normal)
        qrCodeButton.tintColor = UserManager.shared.getAppTheme().colorSkin.tintColor
        qrCodeButton.addTarget(self, action: #selector(didTapQRCode), for: .touchUpInside)
        contentView.addSubview(qrCodeButton)
    }
    private func configureConstraints() {
        avatarView.snp.remakeConstraints { make in
            make.size.equalTo(Constants.AvatarImageSize.large)
            make.leading.top.bottom.equalTo(contentView.layoutMarginsGuide)
        }
        nameLabel.snp.remakeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(Constants.Spacing.medium)
            make.trailing.equalTo(qrCodeButton.snp.leading)
            make.centerY.equalToSuperview()
        }
        qrCodeButton.snp.remakeConstraints { make in
            make.size.equalTo(Constants.IconButtonSize.small)
            make.trailing.equalTo(contentView.layoutMarginsGuide)
            make.centerY.equalToSuperview()
        }
    }
}

