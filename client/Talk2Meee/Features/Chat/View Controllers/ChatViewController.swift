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
import CoreLocation

class ChatViewController: MessagesViewController {
    
    weak var appCoordinator: AppCoordinator?
    private let disposeBag = DisposeBag()
    internal let viewModel: ChatViewModel
    
    // MARK: - Views
    private let chatInputBar = ChatInputBar()
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
        viewModel.loadMessages()
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
        chatInputBar.dismissInputView()
    }
    @objc
    private func didSwipeDownInView(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .down, .up:
            chatInputBar.dismissInputView()
        default:
            return
        }
    }
}

// MARK: - View Config
extension ChatViewController {
    private func configureViews() {
        title = viewModel.getChatTitle()
        configureMessageCollectionView()
        configureInputBar()
    }
    private func configureConstraints() {
        messagesCollectionView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(view.safeAreaLayoutGuide)
            footerBottomConstraint = make.bottom.equalTo(view.layoutMarginsGuide).constraint.layoutConstraints.first
        }
    }
    private func configureMessageCollectionView() {
        messagesCollectionView.backgroundColor = UIColor(hex: UserManager.shared.getChatTheme().backgroundColor)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
    }
    private func configureInputBar() {
        chatInputBar.delegate = self
        chatInputBar.chatInputBarDelegate = self
        chatInputBar.isTranslucent = true
        chatInputBar.separatorLine.isHidden = true
        chatInputBar.stickerPacks = viewModel.stickerPacks
        inputBarType = .custom(chatInputBar)
        messageInputBar = chatInputBar
        messageInputBar.layer.opacity = 1
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
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToLastItem()
                }
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - MessageCollectionView DataSource
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
        guard let sender = viewModel.sender else {
            fatalError("Self sender is nil, user data should be cached")
        }
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return viewModel.displayedMessages.value[indexPath.section]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let chatMessage = viewModel.getMessage(at: indexPath)
        let chatTheme = UserManager.shared.getChatTheme()
        if chatMessage.type.hasBackground {
            if message.sender.senderId == viewModel.sender?.senderId {
                return UIColor(hex: chatTheme.selfMessageBubbleColor)
            } else {
                return UIColor(hex: chatTheme.otherMessageBubbleColor)
            }
        } else {
            return .clear
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let chatTheme = UserManager.shared.getChatTheme()
        if message.sender.senderId == viewModel.sender?.senderId {
            return UIColor(hex: chatTheme.selfMessageBubbleTextColor)
        } else {
            return UIColor(hex: chatTheme.otherMessageBubbleTextColor)
        }
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return viewModel.displayedMessages.value.count
    }
    
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        guard let sender = message.sender as? Sender else { return }
        // TODO
//    }
    
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
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return .zero
    }
}

// MARK: - MessageCollcetionView Delegate
extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = viewModel.getMessage(at: indexPath)
        guard message.type == .image, let imageURL = viewModel.getImageURL(at: indexPath) else { return }
        let viewController = PhotoViewerViewController(appCoordinator: self.appCoordinator, url: imageURL)
        navigationController?.pushViewController(viewController, animated: true)
    }
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = viewModel.getMessage(at: indexPath)
        
        switch message.type {
        case .location:
            guard let content = message.content as? ChatMessageLocationContent else { return }
            let viewController = LocationPickerViewController(appCoordinator: self.appCoordinator,
                                                              coordinates: CLLocationCoordinate2D(latitude: content.latitdue, longitude: content.longtitude),
                                                              isEditable: false)
            navigationController?.pushViewController(viewController, animated: true)
        default:
            return
        }
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        // Add double tap and long press gesture
        if indexPaths.count == 1 {
            let starAction = UIAction(title: "Star", image: UIImage(systemName: Icons.star)) { _ in /* Implement the action. */ }
            let downloadAction = UIAction(title: "Download", image: UIImage(systemName: Icons.squareAndArrowDown)) { [weak self] _ in
                guard let content = self?.viewModel.getMessage(at: indexPaths[0]).content as? ChatMessageImageContent else { return }
                if let url = URL(string: content.imageStoragePath), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
            let replyAction = UIAction(title: "Reply", image: UIImage(systemName: Icons.arrowshapeTurnUpBackward)) { _ in /* Implement the action. */ }
            
            // don't allow to edit message for now
//            let editAction = UIAction(title: "Edit", image: UIImage(systemName: Icons.pencil)) { _ in }
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: Icons.docOnDoc)) { [weak self] _ in
                guard let content = self?.viewModel.getMessage(at: indexPaths[0]).content as? ChatMessageTextContent else { return }
                UIPasteboard.general.string = content.text
            }
            let viewStickerPackAction = UIAction(title: "View Sticker Pack", image: UIImage(systemName: Icons.rectangleOnRectangleCircle)) { [weak self] _ in
                // TODO: - show sticker details page
            }
            let translateAction = UIAction(title: "Translate", image: UIImage(systemName: Icons.characterBubble)) { _ in /* Implement the action. */ }
            let infoAction = UIAction(title: "Info", image: UIImage(systemName: Icons.infoCircle)) { _ in /* Implement the action. */ }
            let unsendAction = UIAction(title: "Unsend", image: UIImage(systemName: Icons.xmark)) { [weak self] _ in
                // TODO: - add unsend
            }
            let moreAction = UIAction(title: "More", image: UIImage(systemName: Icons.ellipsisCircle)) { [weak self] _ in
                // TODO: - forward and delete
            }
            
            let message = viewModel.getMessage(at: indexPaths[0])
            switch message.type {
            case .text:
                if viewModel.isSentByMe(at: indexPaths[0]) {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, copyAction, translateAction, unsendAction, moreAction ])
                    })
                } else {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, copyAction, translateAction, moreAction ])
                    })
                }
            case .image:
                if viewModel.isSentByMe(at: indexPaths[0]) {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, downloadAction, unsendAction, moreAction ])
                    })
                } else {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, downloadAction, moreAction ])
                    })
                }
            case .sticker:
                if viewModel.isSentByMe(at: indexPaths[0]) {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, viewStickerPackAction, unsendAction, moreAction ])
                    })
                } else {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, viewStickerPackAction, moreAction ])
                    })
                }
            case .location:
                if viewModel.isSentByMe(at: indexPaths[0]) {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, unsendAction, moreAction ])
                    })
                } else {
                    return UIContextMenuConfiguration(actionProvider: { suggestedActions in
                        // TODO: - determine by message type and sender
                        return UIMenu(children: [ starAction, replyAction, moreAction ])
                    })
                }
            }
            
            
        } else {
            print("indexPaths multiple or empty...", indexPaths.count)
            return nil
        }
    }
}

// MARK: - InputBar Delegate
extension ChatViewController: InputBarAccessoryViewDelegate, ChatInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        viewModel.sendMessage(for: ChatMessageTextContent(text: text), as: .text)
        chatInputBar.clearTextView()
    }
    func chatInputBarDidTapAttachmentButton(_ view: ChatInputBar) {
        presentInputActionSheet()
    }
    func chatInputBar(_ view: ChatInputBar, didSelect stickerID: StickerID, from packID: StickerPackID) {
        viewModel.sendMessage(for: ChatMessageStickerContent(id: stickerID, packID: packID), as: .sticker)
    }
    func chatInputBarShowAddStickerPackView(_ view: ChatInputBar) {
        let viewController = ManageStickerPackViewController(appCoordinator: self.appCoordinator, viewModel: ManageStickerPackViewModel(appCoordinator: self.appCoordinator))
        present(viewController.embedInNavgationController(), animated: true)
    }
}
