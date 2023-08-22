//
//  HomeViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay

class HomeViewModel: Base.ViewModel {
    
    private let chats: BehaviorRelay<[Chat]> = BehaviorRelay(value: [])
    let displayedChats: BehaviorRelay<[Chat]> = BehaviorRelay(value: [])
}

extension HomeViewModel {
    func listenForAllChats() {
        DatabaseManager.shared.listenForAllChats { result in
            switch result {
            case .success(let chats):
                self.chats.accept(chats)
                self.displayedChats.accept(chats)
                SocketChatManger.shared.subscribleToChats()
            case .failure(let error):
                print("Failed fetching chats", error.localizedDescription)
                return
            }
        }
    }
    func getChat(with userID: UserID) async -> Chat? {
        guard let currentUserID = UserManager.shared.currentUserID else { return nil }
        if let currentChat = DatabaseManager.shared.getAllChats().first(where: { $0.members == [currentUserID, userID].sorted() }) {
            return currentChat
        } else {
            let chat = await DatabaseManager.shared.createChat(for: [currentUserID, userID])
            return chat
        }
    }
    func filterChats(for query: String) {
        if query.isEmpty {
            displayedChats.accept(chats.value)
        } else {
            let filteredChats = chats.value.filter({ getChatTitle(for: $0).localizedCaseInsensitiveContains(query) })
            displayedChats.accept(filteredChats)
        }
    }
    func deleteChat(at indexPath: IndexPath) {
        // TODO: 
    }
}

extension HomeViewModel {
    private func getChatTitle(for chat: Chat) -> String {
        guard let currentUserID = UserManager.shared.currentUserID else { return "" }
        return chat.title ?? chat.members.filter({ $0 != currentUserID }).compactMap({ DatabaseManager.shared.getUser($0)?.name }).joined(separator: ", ")
    }
    func getChat(at indexPath: IndexPath) -> Chat {
        return displayedChats.value[indexPath.row]
    }
}

