//
//  UIBarButtonItem+Extension.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/24/23.
//

import UIKit

extension UIBarButtonItem {
    static func initWithThemeColor(image: UIImage?, style: UIBarButtonItem.Style, target: Any?, action: Selector?) -> UIBarButtonItem {
        let item = UIBarButtonItem(image: image, style: style, target: target, action: action)
        item.tintColor = UserManager.shared.getAppTheme().colorSkin.navigationBarItemTintColor
        return item
    }
    static func initWithThemeColor(systemItem: UIBarButtonItem.SystemItem, primaryAction: UIAction? = nil, menu: UIMenu? = nil) -> UIBarButtonItem {
        let item = UIBarButtonItem(systemItem: systemItem, primaryAction: primaryAction, menu: menu)
        item.tintColor = UserManager.shared.getAppTheme().colorSkin.navigationBarItemTintColor
        return item
    }
    static func initWithThemeColor(title: String?, style: UIBarButtonItem.Style, target: Any?, action: Selector?) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: style, target: target, action: action)
        item.tintColor = UserManager.shared.getAppTheme().colorSkin.navigationBarItemTintColor
        return item
    }
    static func initWithThemeColor(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, target: Any?, action: Selector?) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: systemItem, target: target, action: action)
        item.tintColor = UserManager.shared.getAppTheme().colorSkin.navigationBarItemTintColor
        return item
    }
}
