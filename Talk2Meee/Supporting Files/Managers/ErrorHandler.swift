//
//  ErrorHandler.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/18/23.
//

import Foundation
import UIKit

class ErrorHandler {
    static let shared = ErrorHandler()
}

extension ErrorHandler {
    func handle(_ error: Error) {
        print(error)
    }
    
    func createAlert(for error: Error, title: String = "Error") -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        return alert
    }
}
