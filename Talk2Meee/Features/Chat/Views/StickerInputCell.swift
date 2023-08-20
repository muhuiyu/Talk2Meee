//
//  StickerInputCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import FirebaseStorage

class StickerInputCell: UICollectionViewCell, BaseCell {
    static var reuseID: String {
        return NSStringFromClass(StickerInputCell.self)
    }
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var image: UIImage? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = self?.image
            }
        }
    }
}

// MARK: - View Config
extension StickerInputCell {
    private func configureViews() {
        
    }
    private func configureConstraints() {
        
    }
}

