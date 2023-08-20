//
//  ChatViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay

class ChatViewModel: Base.ViewModel {
    
    let chat: Chat
    private let messages: BehaviorRelay<[ChatMessage]> = BehaviorRelay(value: [])
    let displayedMessages: BehaviorRelay<[Message]> = BehaviorRelay(value: [])
    
    private(set) var stickerPacks = UserManager.shared.getStickerPacks()
    
    var sender: Sender? {
        guard let currentUser = UserManager.shared.currentUser else { return nil }
        return Sender(senderId: currentUser.uid, displayName: currentUser.displayName ?? "", photoURL: currentUser.photoURL?.absoluteString ?? "")
    }
    
    init(appCoordinator: AppCoordinator? = nil, chat: Chat) {
        self.chat = chat
        super.init(appCoordinator: appCoordinator)
        
        messages
            .asObservable()
            .subscribe { value in
                let convertedMessages = value.compactMap({ $0.toMessage() })
                self.displayedMessages.accept(convertedMessages)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Listen and send messages
extension ChatViewModel {
    func listenForMessages() {
        DatabaseManager.shared.listenForMessages(for: chat.id) { result in
            switch result {
            case .failure(let error):
                print("Failed fetchMessages(): ", error.localizedDescription)
            case .success(let messages):
                self.messages.accept(messages)
            }
        }
    }
    func sendMessage(_ text: String) {
        // TODO: - see if we need to use our customized id...?
        let newIdentifier = UUID().uuidString
        guard !text.isEmpty, let sender = sender else { return }
//        let message = Message(sender: sender, messageId: newIdentifier, sentDate: Date(), kind: .text(text))
        Task {
            let chatMessage = ChatMessage(id: newIdentifier, sender: sender.senderId, sentTime: Date(), type: .text, content: ChatMessageTextContent(text: text), searchableContent: text)
            let result = await DatabaseManager.shared.sendMessage(to: chat.id, chatMessage)
            sendMessageResultHandler(result)
        }
    }
    func sendMessage(_ stickerID: StickerID, _ packID: StickerPackID) {
        let newIdentifier = UUID().uuidString
        guard let sender = sender else { return }
        Task {
            let chatMessage = ChatMessage(id: newIdentifier, sender: sender.senderId, sentTime: Date(), type: .sticker, content: ChatMessageStickerContent(id: stickerID, packID: packID))
            let result = await DatabaseManager.shared.sendMessage(to: chat.id, chatMessage)
            sendMessageResultHandler(result)
        }
    }
    private func sendMessageResultHandler(_ result: Result<Void, Error>) {
        switch result {
        case .failure(let error):
            print("Error: ", error)
        case .success:
            return
        }
    }
}

// MARK: - Get chat properties
extension ChatViewModel {
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
