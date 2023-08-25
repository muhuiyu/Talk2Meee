//
//  ProfileQRCodeViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/22/23.
//

import UIKit

class ProfileQRCodeViewController: BaseViewController {
    
    private let scanButton = TextButton(buttonType: .primary)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
    }
}

// MARK: - Handlers
extension ProfileQRCodeViewController {
    @objc
    private func didTapShare() {
        
    }
}
// MARK: - View Config
extension ProfileQRCodeViewController {
    private func configureViews() {
        title = "QR Code"
        navigationItem.rightBarButtonItem = UIBarButtonItem.initWithThemeColor(image: UIImage(systemName: Icons.squareAndArrowUp), style: .plain, target: self, action: #selector(didTapShare))
    }
    private func configureConstraints() {
        
    }
}

