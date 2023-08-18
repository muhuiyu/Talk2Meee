//
//  LoginViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import UIKit
import RxSwift
import RxRelay
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import JGProgressHUD

class LoginViewController: Base.MVVMViewController<LoginViewModel> {
    
    private let spinner = JGProgressHUD(style: .dark)
    private let googleSignInButton = GIDSignInButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    
}

// MARK: - Handlers
extension LoginViewController {
    @objc
    private func didTapGoogleSignInButton() {
        spinner.show(in: view)
        Task {
            await viewModel.continueGoogleSignIn(from: self)
            DispatchQueue.main.async { [weak self] in
                self?.spinner.dismiss()
            }
        }
    }
}

// MARK: - View Config
extension LoginViewController {
    private func configureViews() {
        title = "Login"
        googleSignInButton.addTarget(self, action: #selector(didTapGoogleSignInButton), for: .touchUpInside)
        view.addSubview(googleSignInButton)
    }
    private func configureConstraints() {
        googleSignInButton.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalTo(view.layoutMarginsGuide)
        }
    }
    private func configureBindings() {
        
    }
}

