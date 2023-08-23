//
//  ChatViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay
import CoreLocation

class ChatViewModel: Base.ViewModel {
    
    let chat: Chat
    private let messages: BehaviorRelay<[ChatMessage]> = BehaviorRelay(value: [])
    let displayedMessages: BehaviorRelay<[Message]> = BehaviorRelay(value: [])
    private(set) var stickerPacks = UserManager.shared.getStickerPacks()
    
    private var dataObserver: NSObjectProtocol?
    
    var sender: Sender? {
        guard let currentUser = UserManager.shared.currentUser else { return nil }
        return Sender(senderId: currentUser.uid, displayName: currentUser.displayName ?? "", photoURL: currentUser.photoURL?.absoluteString ?? "")
    }
    
    init(appCoordinator: AppCoordinator? = nil, chat: Chat) {
        self.chat = chat
        super.init(appCoordinator: appCoordinator)
        
        configureObservers()
        
        messages
            .asObservable()
            .subscribe { value in
                let convertedMessages = value.compactMap({ $0.toMessage() })
                self.displayedMessages.accept(convertedMessages)
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        removeObservers()
    }
}

// MARK: - Listen and send messages
extension ChatViewModel {
    func loadMessages() {
        let messages = DatabaseManager.shared.getMessages(for: chat.id)
        self.messages.accept(messages)
    }
    func sendMessage(for content: ChatMessageContent, as type: ChatMessageType) {
        let newIdentifier = UUID().uuidString
        guard let sender = sender else { return }
        let chatMessage = ChatMessage(id: newIdentifier, chatID: chat.id, sender: sender.senderId, sentTime: Date(), type: type, content: content, searchableContent: content.getSearchableContent(), quotedMessageID: nil)
        DatabaseManager.shared.sendMessage(chatMessage)
    }
    private func sendMessageResultHandler(_ result: VoidResult) {
        switch result {
        case .failure(let error):
            print("Error: ", error)
        case .success:
            return
        }
    }
}

// MARK: - Delete message
extension ChatViewModel {
    func deleteMessage(at indexPath: IndexPath) {
        
    }
}

// MARK: - Get chat properties
extension ChatViewModel {
    func isSentByMe(at indexPath: IndexPath) -> Bool {
        let message = messages.value[indexPath.section]
        return message.sender == sender?.senderId
    }
    func getMessage(at indexPath: IndexPath) -> ChatMessage {
        return messages.value[indexPath.section]
    }
    func getImageURL(at indexPath: IndexPath) -> URL? {
        guard let content = messages.value[indexPath.section].content as? ChatMessageImageContent else { return nil }
        return URL(string: content.imageStoragePath)
    }
    func getChatImageURL() -> String? {
        if let imageURL = chat.imageStoragePath, !imageURL.isEmpty {
            return imageURL
        } else if chat.isSingleChat {
            guard
                let currentUserID = UserManager.shared.currentUserID,
                let otherUserID = chat.members.filter({ $0 != currentUserID }).first
            else { return nil }
            let user = DatabaseManager.shared.getUser(otherUserID)
            return user?.photoURL
        } else {
            // TODO: - generate image URL automatically?
            return nil
        }
    }
    func getChatTitle() -> String {
        guard let currentUserID = UserManager.shared.currentUserID else { return "" }
        return chat.title ?? chat.members.filter({ $0 != currentUserID }).compactMap({ DatabaseManager.shared.getUser($0)?.name }).joined(separator: ", ")
    }
    func getChatSubtitle() -> String {
        return chat.lastMessage?.preview ?? ""
    }
}

extension ChatViewModel {
    private func configureObservers() {
        dataObserver = NotificationCenter.default.addObserver(forName: .didUpdateMessages, object: nil, queue: .main, using: { [weak self] _ in
            guard let self = self else { return }
            print("should update messages")
            self.loadMessages()
        })
    }
    private func removeObservers() {
        if let dataObserver = dataObserver {
            NotificationCenter.default.removeObserver(dataObserver)
        }
    }
}
