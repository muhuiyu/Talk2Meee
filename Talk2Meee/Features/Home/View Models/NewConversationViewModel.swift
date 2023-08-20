//
//  NewConversationViewModel.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay

class NewConversationViewModel: Base.ViewModel {
    
    private let users: BehaviorRelay<[ChatUser]> = BehaviorRelay(value: [])
    let displayedUsers: BehaviorRelay<[ChatUser]> = BehaviorRelay(value: [])
    
    private var hasFetched = false
}

extension NewConversationViewModel {
    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            self.filterUsers(with: query)
        } else {
            Task {
                let result = await DatabaseManager.shared.fetchAllUsers()
                hasFetched = true
                
                switch result {
                case .success(let users):
                    self.users.accept(users)
                    self.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error.localizedDescription)")
                }
            }
        }
    
    }
    
    private func filterUsers(with query: String) {
        guard hasFetched else { return }
        if query.isEmpty {
            displayedUsers.accept([])
        } else {
            let filteredUsers = users.value.filter({ $0.name.localizedCaseInsensitiveContains(query) })
            displayedUsers.accept(filteredUsers)
        }
    }
}

