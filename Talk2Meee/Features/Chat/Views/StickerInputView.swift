//
//  StickerInputView.swift
//  Talk2Meee
//
//  Created by Grace, Mu-Hui Yu on 8/19/23.
//

import UIKit

protocol StickerInputViewDelegate: AnyObject {
    func stickerInputViewDidTapDone(_ view: StickerInputView)
    func stickerInputView(_ view: StickerInputView, didSelect stickerID: StickerID, from packID: StickerPackID)
}

class StickerInputView: UIInputView {
    
    private let stickerView = UIView()
    private let doneButton = UIButton()
    
    weak var delegate: StickerInputViewDelegate?
    
    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: .zero, inputViewStyle: .default)
        configureViews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stickerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(240)
        }
    }
}

// MARK: - View Config
extension StickerInputView {
    @objc
    private func didTapDone() {
        delegate?.stickerInputViewDidTapDone(self)
    }
    private func configureViews() {
//        let stickerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        stickerView.backgroundColor = .purple

        let doneButton = UIButton(frame: CGRect(x: stickerView.frame.width - 60, y: 10, width: 50, height: 30))
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        stickerView.addSubview(doneButton)
        addSubview(stickerView)
    }
    private func configureConstraints() {
        stickerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(240)
        }
    }
}


