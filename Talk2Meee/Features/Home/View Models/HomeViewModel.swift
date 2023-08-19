//
//  HomeViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseAuth

class HomeViewModel: Base.ViewModel {
    
    private let chats: BehaviorRelay<[Chat]> = BehaviorRelay(value: [])
    let displayedChats: BehaviorRelay<[Chat]> = BehaviorRelay(value: [])
}

extension HomeViewModel {
    func fetchChats() {
        Task {
            let result = await DatabaseManager.shared.fetchChats()
            switch result {
            case .success(let chats):
                self.chats.accept(chats)
                self.displayedChats.accept(chats)
            case .failure(let error):
                print("Failed fetching chats", error.localizedDescription)
                return
            }
        }
    }
    func fetchChat(with userID: UserID) async -> Chat? {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return nil }
        let result = await DatabaseManager.shared.fetchChat([ currentUserID, userID ])
        switch result {
        case .failure(let error):
            print("Failed fetching chat", error.localizedDescription)
            return nil
        case .success(let chat):
            return chat
        }
    }
    func fetchChat(of memberIDs: [UserID]) async -> Chat? {
        return nil 
    }
    func filterChats(for query: String) {
        if query.isEmpty {
            displayedChats.accept(chats.value)
        } else {
            let filteredChats = chats.value.filter({ getChatTitle(for: $0).localizedCaseInsensitiveContains(query) })
            displayedChats.accept(filteredChats)
        }
    }
}

extension HomeViewModel {
    private func getChatTitle(for chat: Chat) -> String {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return "" }
        return chat.title ?? chat.members.filter({ $0 != currentUserID }).compactMap({ DatabaseManager.shared.getUser($0)?.name }).joined(separator: ", ")
    }
    func getChatTitle(at indexPath: IndexPath) -> String {
        let chat = displayedChats.value[indexPath.row]
        return getChatTitle(for: chat)
    }
    func getChatSubtitle(at indexPath: IndexPath) -> String {
        let chat = displayedChats.value[indexPath.row]
        return chat.lastMessage?.preview ?? ""
    }
}

