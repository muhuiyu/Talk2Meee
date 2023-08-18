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

//class ChatViewController: Base.MVVMViewController<ChatViewModel> {
class ChatViewController: MessagesViewController {
        
    private var messages = [Message]()
    private var selfSender = Sender(senderId: "mikan123",
                                    displayName: "Mikan",
                                    photoURL: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Testing
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date.now,
                                kind: .text("How are you doing?")))
        messages.append(Message(sender: selfSender,
                                messageId: "2",
                                sentDate: Date.now,
                                kind: .text("Wanna hangout and get some food?")))
        
        configureViews()
        configureConstraints()
        configureBindings()
        
        DispatchQueue.main.async { [weak self] in
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToLastItem()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

// MARK: - View Config
extension ChatViewController {
    private func configureViews() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    private func configureConstraints() {
        
    }
    private func configureBindings() {
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    var currentSender: MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        // MessageKit uses Section to select messages
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

