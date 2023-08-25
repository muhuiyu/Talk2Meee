//
//  ChatPreviewCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxRelay
import RxSwift
import Kingfisher

class ChatPreviewCell: UITableViewCell, BaseCell {
    static var reuseID: String {
        return NSStringFromClass(ChatPreviewCell.self)
    }
    
    // MARK: - Views
    private let photoView = UIImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let previewLabel = UILabel()
    
    // MARK: - Data
    private let disposeBag = DisposeBag()
    
    var viewModel: ChatViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            if let imageURL = viewModel.getChatImageURL() {
                let placeholder = UIImage(systemName: Icons.personCropCircle)
                photoView.kf.setImage(with: URL(string: imageURL), placeholder: placeholder)
            }
            titleLabel.text = viewModel.getChatTitle()
            previewLabel.text = viewModel.getChatSubtitle()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoView.roundCorners(corners: .allCorners, radius: Constants.ImageSize.thumbnail / 2)
    }
}

// MARK: - View Config
extension ChatPreviewCell {
    private func configureViews() {
        photoView.contentMode = .scaleToFill
        photoView.clipsToBounds = true
        contentView.addSubview(photoView)
        
        titleLabel.textAlignment = .left
        titleLabel.textColor = UserManager.shared.getAppTheme().colorSkin.labelColor
        titleLabel.font = .bodyBold
        stackView.addArrangedSubview(titleLabel)
        
        previewLabel.textAlignment = .left
        previewLabel.textColor = UserManager.shared.getAppTheme().colorSkin.secondaryLabelColor
        previewLabel.font = .small
        stackView.addArrangedSubview(previewLabel)
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Constants.Spacing.trivial
        contentView.addSubview(stackView)
    }
    private func configureConstraints() {
        photoView.snp.remakeConstraints { make in
            make.leading.top.bottom.equalTo(contentView.layoutMarginsGuide)
            make.centerY.equalToSuperview()
            make.size.equalTo(Constants.ImageSize.thumbnail)
        }
        stackView.snp.remakeConstraints { make in
            make.leading.equalTo(photoView.snp.trailing).offset(Constants.Spacing.medium)
            make.top.equalTo(photoView)
            make.trailing.equalTo(contentView.layoutMarginsGuide)
        }
    }
}

