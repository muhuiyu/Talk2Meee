//
//  AppColorSkin+Green.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/24/23.
//
import UIKit

extension AppColorSkin {
    // MARK: - Green
    static let green01: AppColorSkin = AppColorSkin(
        tintColor: UIColor(red: 35.0/255.0, green: 176.0/255.0, blue: 97.0/255.0, alpha: 1),
        labelColor: UIColor(hex: "3a3a3a"),
        secondaryLabelColor: UIColor(hex: "3a3a3a").withAlphaComponent(0.7),
        backgroundColor: .systemBackground,
        navigationBarBackgroundColor: UIColor(red: 35.0/255.0, green: 176.0/255.0, blue: 97.0/255.0, alpha: 1),
        navigationBarItemTintColor: .white,
        tabBarColor: UIColor(red: 35.0/255.0, green: 176.0/255.0, blue: 97.0/255.0, alpha: 1),
        tabBarItemSelectedTintColor: .white,
        tabBarItemNormalTintColor: UIColor(hex: "054823"),
        chatListBackgroundColor: UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 238.0/255.0, alpha: 1),
        sectionHeaderBackgroundColor: UIColor(red: 1, green: 1, blue: 244.0/255.0, alpha: 1),
        sectionHeaderTextColor: UIColor(red: 35.0/255.0, green: 176.0/255.0, blue: 97.0/255.0, alpha: 1),
        chatroomMenuBackgroundColor: UIColor(red: 19.0/255.0, green: 134.0/255.0, blue: 74.0/255.0, alpha: 1),
        chatroomBackgroundColor: UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 226.0/255.0, alpha: 1),
        otherChatBubbleColor: .white,
        otherChatBubbleTextColor: UIColor(hex: "3a3a3a"),
        selfChatBubbleColor: UIColor(red: 43.0/255.0, green: 181.0/255.0, blue: 104.0/255.0, alpha: 1),
        selfChatBubbleTextColor: UIColor(hex: "3a3a3a"),
        chatInputBarBackgroundColor: UIColor(red: 20.0/255.0, green: 144.0/255.0, blue: 76.0/255.0, alpha: 1),
        chatInputBarTintColor: .white,
        chatInputBarTextFieldBackgroundColor: UIColor(hex: "75d5a4"),
        chatInputBarTextFieldTextColor: UIColor(red: 20.0/255.0, green: 144.0/255.0, blue: 76.0/255.0, alpha: 1),
        chatInputBarInputViewBackgroundColor: UIColor(red: 34.0/255.0, green: 160.0/255.0, blue: 90.0/255.0, alpha: 1)
    )
//    static let green02: AppColorSkin = AppColorSkin(
//        labelColor: <#T##UIColor#>,
//        secondaryLabelColor: <#T##UIColor#>,
//        navigationBarBackgroundColor: <#T##UIColor#>,
//        navigationBarItemTintColor: <#T##UIColor#>,
//        tabBarColor: <#T##UIColor#>,
//        tabBarItemSelectedTintColor: <#T##UIColor#>,
//        tabBarItemNormalTintColor: <#T##UIColor#>,
//        chatListBackgroundColor: <#T##UIColor#>,
//        sectionHeaderBackgroundColor: <#T##UIColor#>,
//        sectionHeaderTextColor: <#T##UIColor#>,
//        chatroomMenuBackgroundColor: <#T##UIColor#>,
//        chatroomBackgroundColor: <#T##UIColor#>,
//        otherChatBubbleColor: <#T##UIColor#>,
//        otherChatBubbleTextColor: <#T##UIColor#>,
//        selfChatBubbleColor: <#T##UIColor#>,
//        selfChatBubbleTextColor: <#T##UIColor#>,
//        chatInputBarBackgroundColor: <#T##UIColor#>,
//        chatInputBarTintColor: <#T##UIColor#>,
//        chatInputBarTextFieldBackgroundColor: <#T##UIColor#>,
//        chatInputBarTextFieldTextColor: <#T##UIColor#>,
//        chatInputBarInputViewBackgroundColor: <#T##UIColor#>
//    )
//    static let green03: AppColorSkin = AppColorSkin(
//        labelColor: <#T##UIColor#>,
//        secondaryLabelColor: <#T##UIColor#>,
//        navigationBarBackgroundColor: <#T##UIColor#>,
//        navigationBarItemTintColor: <#T##UIColor#>,
//        tabBarColor: <#T##UIColor#>,
//        tabBarItemSelectedTintColor: <#T##UIColor#>,
//        tabBarItemNormalTintColor: <#T##UIColor#>,
//        backgroundColor: <#T##UIColor#>,
//        sectionHeaderBackgroundColor: <#T##UIColor#>,
//        sectionHeaderTextColor: <#T##UIColor#>,
//        chatroomMenuBackgroundColor: <#T##UIColor#>,
//        chatroomBackgroundColor: <#T##UIColor#>,
//        otherChatBubbleColor: <#T##UIColor#>,
//        otherChatBubbleTextColor: <#T##UIColor#>,
//        selfChatBubbleColor: <#T##UIColor#>,
//        selfChatBubbleTextColor: <#T##UIColor#>,
//        chatInputBarBackgroundColor: <#T##UIColor#>,
//        chatInputBarTintColor: <#T##UIColor#>,
//        chatInputBarTextFieldBackgroundColor: <#T##UIColor#>,
//        chatInputBarTextFieldTextColor: <#T##UIColor#>,
//        chatInputBarInputViewBackgroundColor: <#T##UIColor#>
//    )
//    static let green05: AppColorSkin = AppColorSkin(
//        labelColor: <#T##UIColor#>,
//        secondaryLabelColor: <#T##UIColor#>,
//        navigationBarBackgroundColor: <#T##UIColor#>,
//        navigationBarItemTintColor: <#T##UIColor#>,
//        tabBarColor: <#T##UIColor#>,
//        tabBarItemSelectedTintColor: <#T##UIColor#>,
//        tabBarItemNormalTintColor: <#T##UIColor#>,
//        backgroundColor: <#T##UIColor#>,
//        sectionHeaderBackgroundColor: <#T##UIColor#>,
//        sectionHeaderTextColor: <#T##UIColor#>,
//        chatroomMenuBackgroundColor: <#T##UIColor#>,
//        chatroomBackgroundColor: <#T##UIColor#>,
//        otherChatBubbleColor: <#T##UIColor#>,
//        otherChatBubbleTextColor: <#T##UIColor#>,
//        selfChatBubbleColor: <#T##UIColor#>,
//        selfChatBubbleTextColor: <#T##UIColor#>,
//        chatInputBarBackgroundColor: <#T##UIColor#>,
//        chatInputBarTintColor: <#T##UIColor#>,
//        chatInputBarTextFieldBackgroundColor: <#T##UIColor#>,
//        chatInputBarTextFieldTextColor: <#T##UIColor#>,
//        chatInputBarInputViewBackgroundColor: <#T##UIColor#>
//    )
//    static let green07: AppColorSkin = AppColorSkin(
//        labelColor: <#T##UIColor#>,
//        secondaryLabelColor: <#T##UIColor#>,
//        navigationBarBackgroundColor: <#T##UIColor#>,
//        navigationBarItemTintColor: <#T##UIColor#>,
//        tabBarColor: <#T##UIColor#>,
//        tabBarItemSelectedTintColor: <#T##UIColor#>,
//        tabBarItemNormalTintColor: <#T##UIColor#>,
//        backgroundColor: <#T##UIColor#>,
//        sectionHeaderBackgroundColor: <#T##UIColor#>,
//        sectionHeaderTextColor: <#T##UIColor#>,
//        chatroomMenuBackgroundColor: <#T##UIColor#>,
//        chatroomBackgroundColor: <#T##UIColor#>,
//        otherChatBubbleColor: <#T##UIColor#>,
//        otherChatBubbleTextColor: <#T##UIColor#>,
//        selfChatBubbleColor: <#T##UIColor#>,
//        selfChatBubbleTextColor: <#T##UIColor#>,
//        chatInputBarBackgroundColor: <#T##UIColor#>,
//        chatInputBarTintColor: <#T##UIColor#>,
//        chatInputBarTextFieldBackgroundColor: <#T##UIColor#>,
//        chatInputBarTextFieldTextColor: <#T##UIColor#>,
//        chatInputBarInputViewBackgroundColor: <#T##UIColor#>
//    )
//    static let green10: AppColorSkin = AppColorSkin(
//        labelColor: <#T##UIColor#>,
//        secondaryLabelColor: <#T##UIColor#>,
//        navigationBarBackgroundColor: <#T##UIColor#>,
//        navigationBarItemTintColor: <#T##UIColor#>,
//        tabBarColor: <#T##UIColor#>,
//        tabBarItemSelectedTintColor: <#T##UIColor#>,
//        tabBarItemNormalTintColor: <#T##UIColor#>,
//        backgroundColor: <#T##UIColor#>,
//        sectionHeaderBackgroundColor: <#T##UIColor#>,
//        sectionHeaderTextColor: <#T##UIColor#>,
//        chatroomMenuBackgroundColor: <#T##UIColor#>,
//        chatroomBackgroundColor: <#T##UIColor#>,
//        otherChatBubbleColor: <#T##UIColor#>,
//        otherChatBubbleTextColor: <#T##UIColor#>,
//        selfChatBubbleColor: <#T##UIColor#>,
//        selfChatBubbleTextColor: <#T##UIColor#>,
//        chatInputBarBackgroundColor: <#T##UIColor#>,
//        chatInputBarTintColor: <#T##UIColor#>,
//        chatInputBarTextFieldBackgroundColor: <#T##UIColor#>,
//        chatInputBarTextFieldTextColor: <#T##UIColor#>,
//        chatInputBarInputViewBackgroundColor: <#T##UIColor#>
//    )
}
