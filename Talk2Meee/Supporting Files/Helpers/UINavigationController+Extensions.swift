//
//  UINavigationController+Extensions.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit

extension UINavigationController {
    
    func removeBottomLine() {
        navigationBar.shadowImage = UIImage()
    }

    /// Finds the view controller instance from the app's navigation stack
    /// - Parameters:
    ///     - class: Class type of the view controller
    /// - Returns: The view controller object of the specified type, returns `nil` if no such view controller is found
    func findViewController<T: UIViewController>(_ class: T.Type) -> T? {
        let viewControllers = self.viewControllers.reversed()
        for viewController in viewControllers {
            if viewController is T {
                return viewController as? T
            }
        }
        return nil
    }
}
