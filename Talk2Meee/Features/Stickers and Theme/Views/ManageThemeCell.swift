//
//  ManageThemeCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/23/23.
//

import UIKit
import Kingfisher

class ManageThemeCell: UICollectionViewCell, BaseCell {
    
    static var reuseID: String { return NSStringFromClass(ManageThemeCell.self) }

    private let isUsingView = UIView()
    private let checkmark = UIImageView(image: UIImage(systemName: Icons.checkmarkCircleFill))
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    var theme: AppTheme? {
        didSet {
            configureData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - View Config
extension ManageThemeCell {
    private func configureData() {
        guard let theme = theme else { return }
        let currentAppTheme = UserManager.shared.getAppTheme()
        isUsingView.isHidden = theme.id != currentAppTheme.id
        let placeholder = UIImage(systemName: Icons.squareFill)
        imageView.kf.setImage(with: URL(string: theme.images.thumbnailURL), placeholder: placeholder)
        titleLabel.text = theme.name
    }
    private func configureViews() {
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        isUsingView.addSubview(checkmark)
        isUsingView.backgroundColor = .black.withAlphaComponent(0.2)
        contentView.addSubview(isUsingView)
        titleLabel.font = .descBold
        contentView.addSubview(titleLabel)
    }
    private func configureConstraints() {
        imageView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(1.25)
        }
        checkmark.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
        isUsingView.snp.remakeConstraints { make in
            make.edges.equalTo(imageView)
        }
        titleLabel.snp.remakeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Constants.Spacing.trivial)
            make.leading.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview()
        }
    }
}
