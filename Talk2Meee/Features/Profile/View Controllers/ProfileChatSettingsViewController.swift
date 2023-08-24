//
//  ProfileChatSettingsViewController.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/23/23.
//

import UIKit
import RxSwift
import RxRelay

class ProfileChatSettingsViewController: BaseViewController {
    
    private let tableView = UITableView()
    
    struct Item {
        let title: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureConstraints()
        configureBindings()
    }
    
}

// MARK: - View Config
extension ProfileChatSettingsViewController {
    private func configureViews() {
        view.addSubview(tableView)
    }
    private func configureConstraints() {
        tableView.snp.remakeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func configureBindings() {
        
    }
}

