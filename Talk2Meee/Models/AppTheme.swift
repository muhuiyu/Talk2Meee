//
//  AppTheme.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/20/23.
//

import Foundation
import UIKit

typealias AppThemeID = String
struct AppTheme {
    var id: AppThemeID
    var name: String
    
    // images
    var previewImageURL: String
    // menuButtonImages
    // TODO: - on and off for chats and profile
    // menuBackgroundImage
    // passcode
    // profileImage
    // chatBackgroundImage
    
    // save colors in hex forms
    
    // TODO: - Change to image
    let backgroundColor: String
    let selfMessageBubbleColor: String
    let otherMessageBubbleColor: String
    let selfMessageBubbleTextColor: String
    let otherMessageBubbleTextColor: String
    let chatInputBarBackgroundColor: String
    let chatInputBarTextFieldColor: String
    
    let navigationBarAppearance: UINavigationBarAppearance
    let tabBarAppearance: UITabBarAppearance
    
    let labelColor: UIColor
    let secondaryLabelColor: UIColor
}

extension AppTheme {
    static var themes: [AppThemeID: AppTheme] = [
        defaultTheme.id: defaultTheme,
        whiteTheme.id: whiteTheme,
        mikanTheme.id: mikanTheme
    ]
    static var defaultTheme: AppTheme {
        return AppTheme(id: "default", name: "Default", previewImageURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fdefault.png?alt=media",
                        backgroundColor: "#ffffff",
                         selfMessageBubbleColor: "#59981A",
                         otherMessageBubbleColor: "#F0F0F0",
                         selfMessageBubbleTextColor: "#ffffff",
                         otherMessageBubbleTextColor: "#000000",
                         chatInputBarBackgroundColor: "#f0f0f0",
                         chatInputBarTextFieldColor: "#f5f5f5",
                        navigationBarAppearance: UINavigationBarAppearance(),
                        tabBarAppearance: UITabBarAppearance(),
                        labelColor: .label,
                        secondaryLabelColor: .secondaryLabel
        )
    }
    static var whiteTheme: AppTheme {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(hex: "#fdfdff")
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(hex: "#323233")]
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "#323233")]
        navigationBarAppearance.buttonAppearance = barButtonAppearance
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor(hex: "#f5f5f8")
        let tabBarItemAppearence = UITabBarItemAppearance()
        tabBarItemAppearence.normal.iconColor = UIColor(hex: "#bdbec0")
        tabBarItemAppearence.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "#bdbec0")]
        tabBarItemAppearence.selected.iconColor = UIColor(hex: "#67686b")
        tabBarItemAppearence.selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "#67686b")]
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearence
        tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearence
        tabBarAppearance.compactInlineLayoutAppearance = tabBarItemAppearence
        
        return AppTheme(id: "whiteTheme", name: "whiteTheme", previewImageURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fmikan.png?alt=media",
                        backgroundColor: "#fbfbfe",
                         selfMessageBubbleColor: "#eceaee",
                         otherMessageBubbleColor: "#eceaee",
                         selfMessageBubbleTextColor: "#676a6b",
                         otherMessageBubbleTextColor: "#676a6b",
                         chatInputBarBackgroundColor: "#FFCC2F",
                         chatInputBarTextFieldColor: "#FFEEA0",
                        navigationBarAppearance: navigationBarAppearance,
                        tabBarAppearance: tabBarAppearance,
                        labelColor: .label,
                        secondaryLabelColor: .secondaryLabel
        )
    }
    
    static var mikanTheme: AppTheme {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(hex: "#ebba56")
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        let barButtonAppearance = UIBarButtonItemAppearance()
        barButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.buttonAppearance = barButtonAppearance
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor(hex: "#ebba56")
        let tabBarItemAppearence = UITabBarItemAppearance()
        tabBarItemAppearence.normal.iconColor = UIColor(hex: "#a78595")
        tabBarItemAppearence.normal.titleTextAttributes = [.foregroundColor: UIColor(hex: "#a78595")]
        tabBarItemAppearence.selected.iconColor = UIColor(hex: "#6d6a4f")
        tabBarItemAppearence.selected.titleTextAttributes = [.foregroundColor: UIColor(hex: "#4C4A37")]
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearence
        tabBarAppearance.inlineLayoutAppearance = tabBarItemAppearence
        tabBarAppearance.compactInlineLayoutAppearance = tabBarItemAppearence
        
        return AppTheme(id: "mikan", name: "Mikan", previewImageURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fmikan.png?alt=media",
                        backgroundColor: "#FFFFD9",
                         selfMessageBubbleColor: "#F7CB61",
                         otherMessageBubbleColor: "#ffffff",
                         selfMessageBubbleTextColor: "#452C14",
                         otherMessageBubbleTextColor: "#452C14",
                         chatInputBarBackgroundColor: "#FFCC2F",
                         chatInputBarTextFieldColor: "#FFEEA0",
                        navigationBarAppearance: navigationBarAppearance,
                        tabBarAppearance: tabBarAppearance,
                        labelColor: .label,
                        secondaryLabelColor: .secondaryLabel
        )
    }
}

struct AppColorSkin {
    let label: UIColor
    let backgroundColor: UIColor
    let tabBarColor: UIColor
}
