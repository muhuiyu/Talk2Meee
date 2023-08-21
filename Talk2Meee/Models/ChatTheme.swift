//
//  ChatTheme.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import Foundation

struct ChatTheme: Codable {
    // save colors in hex forms
    
    // TODO: - Change to image
    let backgroundColor: String
    let selfMessageBubbleColor: String
    let otherMessageBubbleColor: String
    let selfMessageBubbleTextColor: String
    let otherMessageBubbleTextColor: String
    let navigationBarColor: String
    let chatInputBarBackgroundColor: String
    let chatInputBarTextFieldColor: String
}

extension ChatTheme {
    static var defaultTheme: ChatTheme {
        return ChatTheme(backgroundColor: "#ffffff",
                         selfMessageBubbleColor: "#59981A",
                         otherMessageBubbleColor: "#F0F0F0",
                         selfMessageBubbleTextColor: "#ffffff",
                         otherMessageBubbleTextColor: "#000000",
                         navigationBarColor: "#F5F5F5",
                         chatInputBarBackgroundColor: "#f0f0f0",
                         chatInputBarTextFieldColor: "#f5f5f5")
    }
    static var mikanTheme: ChatTheme {
        return ChatTheme(backgroundColor: "#FFC100",
                         selfMessageBubbleColor: "##FFF684",
                         otherMessageBubbleColor: "#ffffff",
                         selfMessageBubbleTextColor: "#1E1C0C",
                         otherMessageBubbleTextColor: "#000000",
                         navigationBarColor: "#FFE159",
                         chatInputBarBackgroundColor: "#FFCC2F",
                         chatInputBarTextFieldColor: "#FFEEA0")
    }
}
