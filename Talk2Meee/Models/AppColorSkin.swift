//
//  AppColorSkin.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/24/23.
//

import UIKit

extension AppColorSkin {
    // MARK: - B/W
    static let bw01: AppColorSkin = AppColorSkin(
        tintColor: .systemBlue,
        labelColor: .black,
        secondaryLabelColor: .secondaryLabel,
        backgroundColor: .systemBackground,
        navigationBarBackgroundColor: UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1),
        navigationBarItemTintColor: .black,
        tabBarColor:  UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 249.0/255.0, alpha: 1),
        tabBarItemSelectedTintColor: .systemBlue,
        tabBarItemNormalTintColor: .secondaryLabel,
        chatListBackgroundColor: .white,
        sectionHeaderBackgroundColor: .white,
        sectionHeaderTextColor: .secondaryLabel,
        chatroomMenuBackgroundColor: UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1),
        chatroomBackgroundColor: UIColor(red: 208.0/255.0, green: 218.0/255.0, blue: 228.0/255.0, alpha: 1),
        otherChatBubbleColor: .white,
        otherChatBubbleTextColor: .black,
        selfChatBubbleColor: UIColor(red: 141.0/255.0, green: 211.0/255.0, blue: 50.0/255.0, alpha: 1),
        selfChatBubbleTextColor: .black,
        chatInputBarBackgroundColor: UIColor(red: 252.0/255.0, green: 252.0/255.0, blue: 252.0/255.0, alpha: 1),
        chatInputBarTintColor: UIColor(hex: "737578"),
        chatInputBarTextFieldBackgroundColor: UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 249.0/255.0, alpha: 1),
        chatInputBarTextFieldTextColor: UIColor(hex: "737578"),
        chatInputBarInputViewBackgroundColor: .white
    )
    // MARK: - Yellow
    static let yellow03: AppColorSkin = AppColorSkin(
        tintColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1),
        labelColor: UIColor(hex: "4f3216"),
        secondaryLabelColor: UIColor(hex: "4f3216").withAlphaComponent(0.7),
        backgroundColor: .systemBackground,
        navigationBarBackgroundColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1),
        navigationBarItemTintColor: .white,
        tabBarColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1),
        tabBarItemSelectedTintColor: UIColor(hex: "673E2E"),
        tabBarItemNormalTintColor: UIColor(hex: "CB9C4C"),
        chatListBackgroundColor: UIColor(red: 1, green: 1, blue: 247.0/255.0, alpha: 1),
        sectionHeaderBackgroundColor: UIColor(red: 1, green: 254.0/255.0, blue: 226.0/255.0, alpha: 1),
        sectionHeaderTextColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1),
        chatroomMenuBackgroundColor: UIColor(red: 252.0/255.0, green: 227.0/255.0, blue: 149.0/255.0, alpha: 1),
        chatroomBackgroundColor: UIColor(red: 1, green: 255.0/255.0, blue: 247.0/255.0, alpha: 1),
        otherChatBubbleColor: .white,
        otherChatBubbleTextColor: UIColor(hex: "4f3216"),
        selfChatBubbleColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1),
        selfChatBubbleTextColor: UIColor(hex: "4f3216"),
        chatInputBarBackgroundColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1),
        chatInputBarTintColor: .white,
        chatInputBarTextFieldBackgroundColor: UIColor(hex: "ffd46e"),
        chatInputBarTextFieldTextColor: UIColor(hex: "4f3216"),
        chatInputBarInputViewBackgroundColor: UIColor(red: 1, green: 201.0/255.0, blue: 72.0/255.0, alpha: 1)
    )
}
