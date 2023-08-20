//
//  ChatViewController+Keyboard.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - Keyboard
extension ChatViewController {
    internal func configureNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHeightWillChange(_:)), name: UIView.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIView.keyboardWillHideNotification, object: nil)
    }
    @objc
    private func keyboardHeightWillChange(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIView.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        animateKeyboard(to: keyboardFrame.height, userInfo: notification.userInfo)
        messagesCollectionView.scrollToLastItem()
    }
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        animateKeyboard(to: 0, userInfo: notification.userInfo)
        messagesCollectionView.scrollToLastItem()
    }
    private func animateKeyboard(to height: CGFloat, userInfo: [AnyHashable : Any]?) {
        let duration = userInfo?[UIView.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let animationCurveRawValue = userInfo?[UIView.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve.RawValue
        let animationOptions: UIView.AnimationOptions
        switch animationCurveRawValue {
        case UIView.AnimationCurve.linear.rawValue:
            animationOptions = .curveLinear
        case UIView.AnimationCurve.easeIn.rawValue:
            animationOptions = .curveEaseIn
        case UIView.AnimationCurve.easeOut.rawValue:
            animationOptions = .curveEaseOut
        case UIView.AnimationCurve.easeInOut.rawValue:
            animationOptions = .curveEaseInOut
        default:
            animationOptions = .curveEaseInOut
        }
        footerBottomConstraint?.constant = -height
        UIView.animate(withDuration: duration, delay: 0, options: [animationOptions, .beginFromCurrentState], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
