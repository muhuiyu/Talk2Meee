//
//  ChatInputTextField.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

protocol ChatInputTextFieldDelegate: AnyObject {
    func chatInputTextField(_ view: ChatInputTextField, didSelect stickerID: StickerID, from packID: StickerPackID)
    func chatInputTextFieldDidTapAddStickerPackButton(_ view: ChatInputTextField)
}

class ChatInputTextField: UIView {
    
    let inputTextView = InputTextView()
    private let stickerButton = InputBarButtonItem()
    private let stickerTextField = UITextField()
    var stickerInputView = StickerInputView()
    
    private var isShowingStickerPanel = false
    
    var inputBarAccessoryView: InputBarAccessoryView? {
        didSet {
            inputTextView.inputBarAccessoryView = inputBarAccessoryView
        }
    }
    
    weak var delegate: ChatInputTextFieldDelegate?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatInputTextField {
    func dismissInputView(shouldKeepTextInputView: Bool = false, shouldKeepStickerInputView: Bool = false) {
        if !shouldKeepTextInputView {
            inputTextView.resignFirstResponder()
        }
        if !shouldKeepStickerInputView {
            stickerTextField.resignFirstResponder()
        }
        reconfigureStickerButton()
//        dismissKeyboard()
    }
}

// MARK: - View Config
extension ChatInputTextField {
    private func configureViews() {
        stickerInputView.allowsSelfSizing = true
        stickerTextField.inputView = stickerInputView
        stickerInputView.delegate = self
        
        inputTextView.delegate = self
        inputTextView.returnKeyType = .next
        addSubview(inputTextView)
        stickerButton.setSize(CGSize(width: 32, height: 32), animated: false)
        stickerButton.setImage(UIImage(systemName: Icons.faceSmiling), for: .normal)
        stickerButton.onTouchUpInside { [weak self] _ in
            self?.didTapStickerButton()
        }
        addSubview(stickerButton)
        stickerTextField.isHidden = true
        addSubview(stickerTextField)
        layer.borderWidth = 1.0
        layer.cornerRadius = 16.0
        layer.masksToBounds = true
        backgroundColor = UIColor(hex: UserManager.shared.getAppTheme().chatInputBarTextFieldColor)
    }
    private func configureConstraints() {
        inputTextView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalToSuperview().inset(8)
            make.trailing.equalTo(stickerButton.snp.leading).offset(-12)
        }
        stickerButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        stickerTextField.snp.remakeConstraints { make in
            make.edges.equalTo(stickerButton)
        }
    }
    private func didTapStickerButton() {
        if self.stickerTextField.isFirstResponder {
            // close sticker
            self.inputTextView.becomeFirstResponder()
            self.stickerTextField.resignFirstResponder()
        } else {
            self.inputTextView.resignFirstResponder()
            self.stickerTextField.becomeFirstResponder()
        }
        isShowingStickerPanel = !isShowingStickerPanel
        reconfigureStickerButton()
    }
    private func reconfigureStickerButton() {
        stickerButton.setImage(UIImage(systemName: isShowingStickerPanel ? Icons.keyboard : Icons.faceSmiling), for: .normal)
    }
}

extension ChatInputTextField: StickerInputViewDelegate, UITextViewDelegate {
    func stickerInputView(_ view: StickerInputView, didSelect stickerID: StickerID, from packID: StickerPackID) {
        delegate?.chatInputTextField(self, didSelect: stickerID, from: packID)
    }
    func stickerInputViewDidTapAddStickerPackButton(_ view: StickerInputView) {
        delegate?.chatInputTextFieldDidTapAddStickerPackButton(self)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == inputTextView {
            dismissInputView(shouldKeepTextInputView: true)
        }
    }
}
