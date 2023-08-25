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
    var images: AppThemeImages
    let colorSkin: AppColorSkin
    
    var navigationBarAppearance: UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = colorSkin.navigationBarBackgroundColor
        appearance.titleTextAttributes = [.foregroundColor: colorSkin.navigationBarItemTintColor]
        let buttonAppearance = UIBarButtonItemAppearance(style: .plain)
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: colorSkin.navigationBarItemTintColor]
        buttonAppearance.disabled.titleTextAttributes = [.foregroundColor: colorSkin.navigationBarItemTintColor]
        buttonAppearance.highlighted.titleTextAttributes = [.foregroundColor: colorSkin.navigationBarItemTintColor]
        buttonAppearance.focused.titleTextAttributes = [.foregroundColor: colorSkin.navigationBarItemTintColor]
        appearance.buttonAppearance = buttonAppearance
        appearance.backButtonAppearance = buttonAppearance
        appearance.doneButtonAppearance = buttonAppearance
        return appearance
    }
    
    var tabBarAppearance: UITabBarAppearance {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = colorSkin.tabBarColor
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = colorSkin.tabBarItemNormalTintColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: colorSkin.tabBarItemNormalTintColor]
        itemAppearance.selected.iconColor = colorSkin.tabBarItemSelectedTintColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: colorSkin.tabBarItemSelectedTintColor]
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        return appearance
    }
}

extension AppTheme {
    static var themes: [AppThemeID: AppTheme] = [
        defaultTheme.id: defaultTheme,
        kaeruTheme.id: kaeruTheme,
//        mikanTheme.id: mikanTheme
    ]
    static var defaultTheme: AppTheme {
        return AppTheme(id: "default",
                        name: "Default",
                        images: AppThemeImages(thumbnailURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fdefault.png?alt=media", menuButtonSelectedImageURLs: [:], menuButtonNormalImageURLs: [:]),
                        colorSkin: AppColorSkin.bw01)
    }
    
    static var kaeruTheme: AppTheme {
        let thumbnailURL = "https://shop.line-scdn.net/themeshop/v1/products/3f/11/ec/3f11eca5-d270-4148-b570-eacdabbed4d9/89/WEBSTORE/icon_198x278.png"
        let tabBarItemSelectedImageURL = "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fkaeru%2Ftab-on.png?alt=media"
        let tabBarItemNormalImageURL = "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fkaeru%2Ftab-off.png?alt=media"
        let chatroomBackgroundImageURL = "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fkaeru%2Fchatroom-background.png?alt=media"
        return AppTheme(id: "kaeruTheme",
                        name: "カエル",
                        images: AppThemeImages(thumbnailURL: thumbnailURL, menuButtonSelectedImageURLs: [.home: tabBarItemSelectedImageURL, .profile: tabBarItemSelectedImageURL], menuButtonNormalImageURLs: [.home: tabBarItemNormalImageURL, .profile: tabBarItemNormalImageURL], chatroomBackgroundImageURL: chatroomBackgroundImageURL),
                        colorSkin: AppColorSkin(tintColor: UIColor(hex: "431816"), labelColor: UIColor(hex: "431816"), secondaryLabelColor: UIColor(hex: "6D8E31"), backgroundColor: .systemBackground, navigationBarBackgroundColor: UIColor(hex: "F5F7EA"), navigationBarItemTintColor: UIColor(hex: "431816"), tabBarColor: UIColor(hex: "EFF0EC"), tabBarItemSelectedTintColor: UIColor(hex: "4B473E"), tabBarItemNormalTintColor: UIColor(hex: "657131"), chatListBackgroundColor: UIColor(hex: "F5F7EA"), sectionHeaderBackgroundColor: UIColor(hex: "F5F7EA"), sectionHeaderTextColor: UIColor(hex: "431816"), chatroomMenuBackgroundColor: UIColor(hex: "F5F7EA"), chatroomBackgroundColor: UIColor(hex: "E3EAE7"), otherChatBubbleColor: .white, otherChatBubbleTextColor: .black, selfChatBubbleColor: UIColor(hex: "B0CC59"), selfChatBubbleTextColor: .black, chatInputBarBackgroundColor: .white, chatInputBarTintColor: UIColor(hex: "4B473E"), chatInputBarTextFieldBackgroundColor: UIColor(hex: "FCFEF5"), chatInputBarTextFieldTextColor: UIColor(hex: "4B473E"), chatInputBarInputViewBackgroundColor: .white))
    }
//
//    static var mikanTheme: AppTheme {
//        return AppTheme(id: "mikan", name: "Mikan", previewImageURL: "https://firebasestorage.googleapis.com/v0/b/hey-there-muyuuu.appspot.com/o/themes%2Fmikan.png?alt=media",
//                        backgroundColor: "#FFFFD9",
//                         selfMessageBubbleColor: "#F7CB61",
//                         otherMessageBubbleColor: "#ffffff",
//                         selfMessageBubbleTextColor: "#452C14",
//                         otherMessageBubbleTextColor: "#452C14",
//                         chatInputBarBackgroundColor: "#FFCC2F",
//                         chatInputBarTextFieldColor: "#FFEEA0",
//                        navigationBarAppearance: navigationBarAppearance,
//                        tabBarAppearance: tabBarAppearance,
//                        labelColor: .label,
//                        secondaryLabelColor: .secondaryLabel
//        )
//    }
}

struct AppThemeImages {
    // TODO: - Add remaining images
    var thumbnailURL: String                                        // 200 x 284
    var menuButtonSelectedImageURLs: [TabBarCategory: String?]      // 128 x 150
    var menuButtonNormalImageURLs: [TabBarCategory: String?]        // 128 x 150
//    var userProfileDefaultImageURL: String
//    var groupProfileDefaultImageURL: String
    var chatroomBackgroundImageURL: String? = nil                   // 1482 × 1334 px
}

struct AppColorSkin {
    // general color
    let tintColor: UIColor
    let labelColor: UIColor
    let secondaryLabelColor: UIColor
    let backgroundColor: UIColor
    
    // navigation
    let navigationBarBackgroundColor: UIColor
    let navigationBarItemTintColor: UIColor     // for done, back, title, and other items
    
    // tab bar
    let tabBarColor: UIColor
    let tabBarItemSelectedTintColor: UIColor
    let tabBarItemNormalTintColor: UIColor
    
    // chatList
    let chatListBackgroundColor: UIColor
    let sectionHeaderBackgroundColor: UIColor
    let sectionHeaderTextColor: UIColor
    
    // chat room
    let chatroomMenuBackgroundColor: UIColor
    let chatroomBackgroundColor: UIColor
    
    // chat bubble
    let otherChatBubbleColor: UIColor
    let otherChatBubbleTextColor: UIColor
    let selfChatBubbleColor: UIColor
    let selfChatBubbleTextColor: UIColor
    
    // chat input bar
    let chatInputBarBackgroundColor: UIColor     // same as tabBarBackgroundColor
    let chatInputBarTintColor: UIColor
    let chatInputBarTextFieldBackgroundColor: UIColor
    let chatInputBarTextFieldTextColor: UIColor
    let chatInputBarInputViewBackgroundColor: UIColor
}
