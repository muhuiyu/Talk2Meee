//
//  ChatAddAttachmentButton.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatAddAttachmentButton: InputBarButtonItem {
    
    var tapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSize(CGSize(width: 35, height: 44), animated: false)
        setImage(UIImage(systemName: Icons.plus), for: .normal)
        onTouchUpInside { [weak self] _ in
            self?.tapHandler?()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
