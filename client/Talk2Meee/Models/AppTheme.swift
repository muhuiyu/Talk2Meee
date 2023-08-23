//
//  AppTheme.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import Foundation

typealias AppThemeID = String
struct AppTheme: Codable {
    var id: AppThemeID
    var name: String
    var previewImageURL: String
    
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

extension AppTheme {
    static var defaultTheme: AppTheme {
        return AppTheme(id: "default", name: "Default", previewImageURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fdefault.png?alt=media",
                        backgroundColor: "#ffffff",
                         selfMessageBubbleColor: "#59981A",
                         otherMessageBubbleColor: "#F0F0F0",
                         selfMessageBubbleTextColor: "#ffffff",
                         otherMessageBubbleTextColor: "#000000",
                         navigationBarColor: "#F5F5F5",
                         chatInputBarBackgroundColor: "#f0f0f0",
                         chatInputBarTextFieldColor: "#f5f5f5")
    }
    static var mikanTheme: AppTheme {
        return AppTheme(id: "mikan", name: "Mikan", previewImageURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fmikan.png?alt=media",
                        backgroundColor: "#FFC100",
                         selfMessageBubbleColor: "##FFF684",
                         otherMessageBubbleColor: "#ffffff",
                         selfMessageBubbleTextColor: "#1E1C0C",
                         otherMessageBubbleTextColor: "#000000",
                         navigationBarColor: "#FFE159",
                         chatInputBarBackgroundColor: "#FFCC2F",
                         chatInputBarTextFieldColor: "#FFEEA0")
    }
}
