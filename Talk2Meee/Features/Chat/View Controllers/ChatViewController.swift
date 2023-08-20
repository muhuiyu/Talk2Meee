//
//  ChatViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay
import MessageKit
import InputBarAccessoryView
import Kingfisher

class ChatViewController: MessagesViewController {
    
    weak var appCoordinator: AppCoordinator?
    private let disposeBag = DisposeBag()
    private let viewModel: ChatViewModel
    
    // MARK: - Views
    private let inputTextView = InputTextView()
    private let stickerButton = InputBarButtonItem()
    private let stickerTextField = UITextField()
    private var stickerInputView = UIInputView()
    private var footerBottomConstraint: NSLayoutConstraint? = nil
    
    private var isShowingStickerPanel: Bool { return stickerTextField.isFirstResponder }
    
    init(appCoordinator: AppCoordinator? = nil, viewModel: ChatViewModel) {
        self.viewModel = viewModel
        self.appCoordinator = appCoordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: - Change to signals for stickers? or local storage
        viewModel.fetchStickers()
        
        configureViews()
        configureConstraints()
        configureBindings()
        viewModel.listenForMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Override collectionViews
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            return viewModel.stickers.count
        }
        else {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerInputCell.reuseID, for: indexPath) as? StickerInputCell else {
                return UICollectionViewCell()
            }
            cell.image = viewModel.stickers[indexPath.item].image
            return cell
        } else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            return CGSize(width: 96, height: 96)
        } else {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            return CGSize.zero
        } else {
            return super.collectionView(collectionView, layout: layout, referenceSizeForHeaderInSection: section)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            return CGSize.zero
        } else {
            return super.collectionView(collectionView, layout: layout, referenceSizeForFooterInSection: section)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            return UICollectionReusableView()
        } else {
            return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
          return 1
        } else {
            return super.numberOfSections(in: collectionView)
        }
    }
}

// MARK: - Handlers
extension ChatViewController {
    private func didTapStickerButton() {
        if self.stickerTextField.isFirstResponder {
            // close sticker
            self.inputTextView.becomeFirstResponder()
            self.stickerTextField.resignFirstResponder()
        } else {
            setupStickerView()
            self.inputTextView.resignFirstResponder()
            self.stickerTextField.becomeFirstResponder()
        }
        reconfigureStickerButton()
    }
    @objc
    private func didTapInView() {
        dismissKeyboard()
        inputTextView.resignFirstResponder()
        stickerTextField.resignFirstResponder()
        reconfigureStickerButton()
    }
}

// MARK: - Keyboard
extension ChatViewController {
    @objc
    private func keyboardHeightWillChange(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        animateKeyboard(to: keyboardFrame.height, userInfo: notification.userInfo)
        messagesCollectionView.scrollToLastItem()
    }
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        animateKeyboard(to: 0, userInfo: notification.userInfo)
        messagesCollectionView.scrollToLastItem()
    }
    private func animateKeyboard(to height: CGFloat, userInfo: [AnyHashable : Any]?) {
        let duration = userInfo?[UIView.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let animationCurveRawValue = userInfo?[UIView.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve.RawValue
        let animationOptions: UIView.AnimationOptions
        switch animationCurveRawValue {
        case UIView.AnimationCurve.linear.rawValue:
            animationOptions = .curveLinear
        case UIView.AnimationCurve.easeIn.rawValue:
            animationOptions = .curveEaseIn
        case UIView.AnimationCurve.easeOut.rawValue:
            animationOptions = .curveEaseOut
        case UIView.AnimationCurve.easeInOut.rawValue:
            animationOptions = .curveEaseInOut
        default:
            animationOptions = .curveEaseInOut
        }
        footerBottomConstraint?.constant = -height
        UIView.animate(withDuration: duration, delay: 0, options: [animationOptions, .beginFromCurrentState], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

// MARK: - View Config
extension ChatViewController {
    private func configureViews() {
        title = viewModel.getChatTitle()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        configureInputBar()
    }
    private func configureConstraints() {
        messagesCollectionView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(view.safeAreaLayoutGuide)
            footerBottomConstraint = make.bottom.equalTo(view.layoutMarginsGuide).constraint.layoutConstraints.first
        }
    }
    private func configureGestures() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInView))
        view.addGestureRecognizer(tapRecognizer)
    }
    private func configureBindings() {
        viewModel.displayedMessages
            .asObservable()
            .subscribe { _ in
                DispatchQueue.main.async { [weak self] in
//                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem()
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHeightWillChange(_:)), name: UIView.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIView.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
        guard let sender = viewModel.sender else {
            fatalError("Self sender is nil, user data should be cached")
        }
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        // MessageKit uses Section to select messages
        return viewModel.displayedMessages.value[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return viewModel.displayedMessages.value.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else { return }
        
        switch message.kind {
        case .photo(let item):
            guard let imageURL = item.url else { return }
            imageView.kf.setImage(with: imageURL)
        default:
            return
        }
    }
}

// MARK: - InputBarAccessoryViewDelegate, UITextViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate, UITextViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        viewModel.sendMessage(text)
        inputTextView.text = ""
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == inputTextView {
            stickerTextField.resignFirstResponder()
            reconfigureStickerButton()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let imageData = image.pngData() else { return }
        
        // TODO: - upload image and send message
//        Task {
//            let result = await StorageManager.shared.uploadMessagePhoto(with: imageData, filename: "")
//            switch result {
//            case .success(let urlString):
//                // TODO: -
//
//            case .failure(let error):
//                print("message photo upload error: \(error)")
//            }
//        }
    }
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Camera
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        })
        cameraAction.setValue(UIImage(systemName: Icons.camera), forKey: "image")
        actionSheet.addAction(cameraAction)
        // PhotoLibrary
        let photoLibraryAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        })
        photoLibraryAction.setValue(UIImage(systemName: Icons.photo), forKey: "image")
        actionSheet.addAction(photoLibraryAction)
        // Document
        let documentAction = UIAlertAction(title: "Document", style: .default, handler: { [weak self] _ in
            // TODO: -
        })
        documentAction.setValue(UIImage(systemName: Icons.doc), forKey: "image")
        actionSheet.addAction(documentAction)
        // Location
        let locationAction = UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            // TODO: -
        })
        locationAction.setValue(UIImage(systemName: Icons.mappinAndEllipse), forKey: "image")
        actionSheet.addAction(locationAction)
        // Contact
        let contactAction = UIAlertAction(title: "Contact", style: .default, handler: { [weak self] _ in
            // TODO: -
        })
        contactAction.setValue(UIImage(systemName: Icons.personCropCircle), forKey: "image")
        actionSheet.addAction(contactAction)
        // Cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
}

// MARK: - InputBar UI
extension ChatViewController {
    static let stickerInputViewTag = 999
    
    private func reconfigureStickerButton() {
        stickerButton.setImage(UIImage(systemName: isShowingStickerPanel ? Icons.keyboard : Icons.faceSmiling), for: .normal)
    }
    private func configureInputBar() {
        // InputBar
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        inputBarType = .custom(messageInputBar)
        
        // Left stack
        let addAttachmentButton = InputBarButtonItem()
        addAttachmentButton.setSize(CGSize(width: 35, height: 44), animated: false)
        addAttachmentButton.setImage(UIImage(systemName: Icons.plus), for: .normal)
        addAttachmentButton.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([addAttachmentButton], forStack: .left, animated: true)
        
        // Right stack
        let sendButton = InputBarButtonItem()
        sendButton.setSize(CGSize(width: 35, height: 44), animated: false)
        sendButton.setImage(UIImage(systemName: Icons.arrowUp), for: .normal)
        sendButton.onTouchUpInside { [weak self] _ in
            guard let self = self else { return }
            self.messageInputBar.delegate?.inputBar(self.messageInputBar, didPressSendButtonWith: inputTextView.text)
        }
        sendButton.imageView?.tintColor = .systemBlue
        sendButton.imageView?.layer.cornerRadius = 16
        sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        sendButton.backgroundColor = .cyan
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([sendButton], forStack: .right, animated: true)
        
        // Middle view
        inputTextView.delegate = self
        inputTextView.inputBarAccessoryView = messageInputBar
        inputTextView.returnKeyType = .next
        let middleContentView = UIView()
        middleContentView.addSubview(inputTextView)
        stickerButton.setSize(CGSize(width: 32, height: 32), animated: false)
        stickerButton.setImage(UIImage(systemName: Icons.faceSmiling), for: .normal)
        stickerButton.onTouchUpInside { [weak self] _ in
            self?.didTapStickerButton()
        }
        middleContentView.addSubview(stickerButton)
        stickerTextField.isHidden = true
        middleContentView.addSubview(stickerTextField)
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
        middleContentView.layer.borderWidth = 1.0
        middleContentView.layer.cornerRadius = 16.0
        middleContentView.layer.masksToBounds = true
        middleContentView.backgroundColor = .systemYellow
        messageInputBar.setMiddleContentView(middleContentView, animated: true)
    }
    private func setupStickerView() {
        let stickerView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240), collectionViewLayout: UICollectionViewFlowLayout())
        stickerView.register(StickerInputCell.self, forCellWithReuseIdentifier: StickerInputCell.reuseID)
        stickerView.delegate = self
        stickerView.dataSource = self
        stickerView.tag = ChatViewController.stickerInputViewTag
        stickerInputView = UIInputView(frame: stickerView.frame, inputViewStyle: .default)
        stickerInputView.addSubview(stickerView)
        stickerInputView.allowsSelfSizing = true
        stickerTextField.inputView = stickerInputView
    }
}

// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = viewModel.getMessage(at: indexPath)
        guard message.type == .image, let imageURL = viewModel.getImageURL(at: indexPath) else { return }
        let viewController = PhotoViewerViewController(appCoordinator: self.appCoordinator, url: imageURL)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - DidSelectSticker
extension ChatViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == ChatViewController.stickerInputViewTag {
            // Sticker
            let sticker = viewModel.stickers[indexPath.item]
            viewModel.sendMessage(sticker)
        }
    }
}

// MARK: - ContextMenu
extension ChatViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        // Add double tap and long press gesture
        guard collectionView.tag != ChatViewController.stickerInputViewTag else {
            return nil
        }
        if indexPaths.count == 1 {
//                let message = viewModel.getMessage(at: indexPaths[0])
            return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                // TODO: - determine by message type and sender
                return UIMenu(children: [
                    UIAction(title: "Star", image: UIImage(systemName: Icons.star)) { _ in /* Implement the action. */ },
                    UIAction(title: "Reply", image: UIImage(systemName: Icons.arrowshapeTurnUpBackward)) { _ in /* Implement the action. */ },
                    UIAction(title: "Forward", image: UIImage(systemName: Icons.arrowshapeTurnUpForward)) { _ in /* Implement the action. */ },
                    UIAction(title: "Copy", image: UIImage(systemName: Icons.docOnDoc)) { _ in /* Implement the action. */ },
                    UIAction(title: "Info", image: UIImage(systemName: Icons.infoCircle)) { _ in /* Implement the action. */ },
                    UIAction(title: "Delete", image: UIImage(systemName: Icons.trash), attributes: .destructive) { _ in /* Implement the action. */ }
                ])
            })
        } else {
            print("indexPaths multiple or empty...", indexPaths.count)
            return nil
        }
    }
    
}
