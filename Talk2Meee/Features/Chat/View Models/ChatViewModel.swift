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
    
    init(appCoordinator: AppCoordinator? = nil, chat: Chat) {
        self.chat = chat
        super.init(appCoordinator: appCoordinator)
    }
}

extension ChatViewModel {
    func sendMessage(_ text: String) {
        
    }
}
