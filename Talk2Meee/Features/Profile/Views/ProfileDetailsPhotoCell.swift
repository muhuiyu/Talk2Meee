//
//  ProfileDetailsPhotoCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/22/23.
//

import UIKit
import Kingfisher

class ProfileDetailsPhotoCell: UITableViewCell, BaseCell {
    static var reuseID: String { NSStringFromClass(ProfileDetailsPhotoCell.self) }
    
    private let avatarView = UIImageView()
    private let editButton = UIButton()
    
    var photoURL: String? {
        didSet {
            guard let photoURL = photoURL else { return }
            let placeholder = UIImage(systemName: Icons.personCropCircle)
            avatarView.kf.setImage(with: URL(string: photoURL), placeholder: placeholder)
        }
    }
    
    var tapAvatarHandler: (() -> Void)?
    var tapEditButtonHandler: (() -> Void)?
    
    @objc
    private func didTapEdit() {
        tapEditButtonHandler?()
    }
    @objc
    private func didTapAvatar() {
        tapAvatarHandler?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        avatarView.isUserInteractionEnabled = true
        contentView.addSubview(avatarView)
        editButton.setTitle("Edit", for: .normal)
        editButton.addTarget(self, action: #selector(didTapEdit), for: .touchUpInside)
        editButton.setTitleColor(UserManager.shared.getAppTheme().colorSkin.tintColor, for: .normal)
        editButton.titleLabel?.font = .smallMedium
        contentView.addSubview(editButton)
        avatarView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(Constants.Spacing.medium)
            make.size.equalTo(Constants.AvatarImageSize.enormous)
        }
        editButton.snp.remakeConstraints { make in
            make.size.equalTo(Constants.IconButtonSize.medium)
            make.centerX.equalToSuperview()
            make.top.equalTo(avatarView.snp.bottom).offset(Constants.Spacing.trivial)
            make.bottom.equalToSuperview().inset(Constants.Spacing.medium)
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarView.addGestureRecognizer(tapRecognizer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

