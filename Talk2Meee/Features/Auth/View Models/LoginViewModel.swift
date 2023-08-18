//
//  LoginViewModel.swift
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

class LoginViewModel: Base.ViewModel {
    
}

extension LoginViewModel {
    func continueGoogleSignIn(from viewController: UIViewController) async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign in configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow
        do {
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            
            guard let idToken = signInResult.user.idToken?.tokenString else {
                print("cannot find user or idtoken is not valid")
                return
            }
            
            let authResult = try await Auth.auth().signIn(with: GoogleAuthProvider.credential(withIDToken: idToken, accessToken: signInResult.user.accessToken.tokenString))
            
            guard let email = authResult.user.email else {
                print("cannot find user email")
                return
            }
            
            let userExists = await DatabaseManager.shared.userExists(with: email)
            if !userExists {
                await DatabaseManager.shared.insertUser(authResult.user)
            }
            NotificationCenter.default.post(Notification(name: .didChangeAuthState))
            
        } catch {
            print(error)
            return
        }
    }
}

