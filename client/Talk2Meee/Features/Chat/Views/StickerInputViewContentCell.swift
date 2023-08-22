//
//  StickerInputViewContentCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import Kingfisher

class StickerInputViewContentCell: UICollectionViewCell, BaseCell {
    static var reuseID: String {
        return NSStringFromClass(StickerInputViewContentCell.self)
    }
    
    private var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.snp.remakeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var urlString: String = "" {
        didSet {
            let placeholder = UIImage(systemName: Icons.squareFill)
            placeholder?.withTintColor(.secondaryLabel)
            imageView.kf.setImage(with: URL(string: urlString), placeholder: placeholder)
        }
    }
}
