//
//  ChatSendButton.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatSendButton: InputBarButtonItem {
    var tapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSize(CGSize(width: 35, height: 44), animated: false)
        setImage(UIImage(systemName: Icons.arrowUp), for: .normal)
        imageView?.tintColor = .systemBlue
        imageView?.layer.cornerRadius = 16
        imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        backgroundColor = .cyan
        onTouchUpInside { [weak self] _ in
            self?.tapHandler?()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
