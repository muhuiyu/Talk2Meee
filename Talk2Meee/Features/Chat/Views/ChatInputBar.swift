//
//  ChatInputBar.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

protocol ChatInputBarDelegate: AnyObject {
    func chatInputBarDidTapAttachmentButton(_ view: ChatInputBar)
    func chatInputBar(_ view: ChatInputBar, didSelect stickerID: StickerID, from packID: StickerPackID)
    func chatInputBarShowAddStickerPackView(_ view: ChatInputBar)
}

class ChatInputBar: InputBarAccessoryView {
    
    private let chatInputTextField = ChatInputTextField()
    weak var chatInputBarDelegate: ChatInputBarDelegate?
    
    var stickerPacks: [StickerPack] = [] {
        didSet {
            chatInputTextField.stickerInputView.stickerPacks = stickerPacks
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatInputBar {
    func clearTextView() {
        chatInputTextField.inputTextView.text = ""
    }
    func dismissInputView(shouldKeepTextInputView: Bool = false, shouldKeepStickerInputView: Bool = false) {
        chatInputTextField.dismissInputView(shouldKeepTextInputView: shouldKeepTextInputView,
                                            shouldKeepStickerInputView: shouldKeepStickerInputView)
    }
}

// MARK: - View Config
extension ChatInputBar {
    private func configureViews() {
        // attachment button
        let addAttachmentButton = ChatAddAttachmentButton()
        addAttachmentButton.tapHandler = { [weak self] in
            guard let self = self else { return }
            self.chatInputBarDelegate?.chatInputBarDidTapAttachmentButton(self)
        }
        setLeftStackViewWidthConstant(to: 36, animated: false)
        setStackViewItems([addAttachmentButton], forStack: .left, animated: true)
        
        // send button
        let sendButton = ChatSendButton()
        sendButton.tapHandler = { [weak self] in
            guard let self = self else { return }
            self.delegate?.inputBar(self, didPressSendButtonWith: self.chatInputTextField.inputTextView.text)
        }
        setRightStackViewWidthConstant(to: 36, animated: false)
        setStackViewItems([sendButton], forStack: .right, animated: true)
        
        chatInputTextField.delegate = self
        chatInputTextField.inputBarAccessoryView = self
        setMiddleContentView(chatInputTextField, animated: false)
        
        backgroundColor = UIColor(hex: UserManager.shared.getChatTheme().chatInputBarBackgroundColor)
    }
}

extension ChatInputBar: ChatInputTextFieldDelegate {
    func chatInputTextField(_ view: ChatInputTextField, didSelect stickerID: StickerID, from packID: StickerPackID) {
        chatInputBarDelegate?.chatInputBar(self, didSelect: stickerID, from: packID)
    }
    func chatInputTextFieldDidTapAddStickerPackButton(_ view: ChatInputTextField) {
        chatInputBarDelegate?.chatInputBarShowAddStickerPackView(self)
    }
}
