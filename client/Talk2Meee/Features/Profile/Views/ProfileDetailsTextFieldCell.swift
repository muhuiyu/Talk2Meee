//
//  ProfileDetailsTextFieldCell.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/22/23.
//

import UIKit

class ProfileDetailsTextFieldCell: UITableViewCell, BaseCell {
    static var reuseID: String { NSStringFromClass(ProfileDetailsTextFieldCell.self) }
    
    private let textField = UITextField()
    
    var text: String? {
        get { return textField.text }
        set { textField.text = newValue }
    }
    
    var allowEditing: Bool = true {
        didSet {
            textField.isEnabled = allowEditing
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textField.font = .body
        contentView.addSubview(textField)
        textField.snp.remakeConstraints { make in
            make.edges.equalTo(contentView.layoutMarginsGuide)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

