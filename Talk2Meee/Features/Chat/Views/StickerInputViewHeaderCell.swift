//
//  StickerInputViewHeaderCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import UIKit
import Kingfisher

final class StickerInputViewHeaderCell: UICollectionViewCell, BaseCell {
    static var reuseID: String {
        return NSStringFromClass(StickerInputViewHeaderCell.self)
    }
    
    private var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        imageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var urlString: String = "" {
        didSet {
            let placeholder = UIImage(systemName: Icons.squareFill)
            imageView.kf.setImage(with: URL(string: urlString), placeholder: placeholder)
        }
    }
}
