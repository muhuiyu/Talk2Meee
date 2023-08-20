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
import JGProgressHUD

class ChatViewController: MessagesViewController {
    
    weak var appCoordinator: AppCoordinator?
    private let disposeBag = DisposeBag()
    private let viewModel: ChatViewModel
    
    // MARK: - Views
    private let spinner = JGProgressHUD(style: .dark)
    private let chatInputTextField = ChatInputTextField()    
    internal var footerBottomConstraint: NSLayoutConstraint? = nil
    
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
        configureViews()
        configureConstraints()
        configureBindings()
        configureNotifications()
        viewModel.listenForMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - Handlers
extension ChatViewController {
    @objc
    private func didTapInView() {
        chatInputTextField.dismissInputView()
    }
    @objc
    private func didSwipeDownInView(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .down, .up:
            chatInputTextField.dismissInputView()
        default:
            return
        }
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
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeDownInView(_:)))
        view.addGestureRecognizer(swipeRecognizer)
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
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        viewModel.sendMessage(text)
        chatInputTextField.inputTextView.text = ""
    }
}


// MARK: - InputBar UI
extension ChatViewController {
    private func configureInputBar() {
        // InputBar
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        inputBarType = .custom(messageInputBar)
        
        // Left stack
        let addAttachmentButton = ChatAddAttachmentButton()
        addAttachmentButton.tapHandler = { [weak self] in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([addAttachmentButton], forStack: .left, animated: true)
        
        // Right stack
        let sendButton = ChatSendButton()
        sendButton.tapHandler = { [weak self] in
            guard let self = self else { return }
            self.messageInputBar.delegate?.inputBar(self.messageInputBar,
                                                    didPressSendButtonWith: self.chatInputTextField.inputTextView.text)
        }
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([sendButton], forStack: .right, animated: true)
        
        // Middle view
        chatInputTextField.delegate = self
        chatInputTextField.inputBarAccessoryView = messageInputBar
        chatInputTextField.stickerInputView.stickerPacks = viewModel.stickerPacks
        messageInputBar.setMiddleContentView(chatInputTextField, animated: false)
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
extension ChatViewController: ChatInputTextFieldDelegate {
    func chatInputTextField(_ view: ChatInputTextField, didSelect stickerID: StickerID, from packID: StickerPackID) {
        viewModel.sendMessage(stickerID, packID)
    }
}

// MARK: - ContextMenu
extension ChatViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        // Add double tap and long press gesture
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
