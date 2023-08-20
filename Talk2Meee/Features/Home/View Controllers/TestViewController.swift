
import UIKit
import MessageKit
import InputBarAccessoryView

class CustomMessagesViewController: MessagesViewController, InputBarAccessoryViewDelegate {
    
    let stickerButton = InputBarButtonItem()
    var stickerInputView: UIInputView?

    override func viewDidLoad() {
        super.viewDidLoad()

        messageInputBar.delegate = self
        stickerButton.image = UIImage(systemName: Icons.faceSmiling) // Replace with your sticker button image
        stickerButton.setSize(CGSize(width: 36, height: 36), animated: false)
        stickerButton.addTarget(self, action: #selector(stickerButtonTapped), for: .primaryActionTriggered)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([stickerButton], forStack: .left, animated: false)
    }

    @objc func stickerButtonTapped() {
        if self.messageInputBar.inputTextView.isFirstResponder {
            if self.messageInputBar.inputTextView.inputView == nil {
                setupStickerView()
                self.messageInputBar.inputTextView.reloadInputViews()
            } else {
                self.messageInputBar.inputTextView.inputView = nil
                self.messageInputBar.inputTextView.reloadInputViews()
            }
        } else {
            setupStickerView()
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    func setupStickerView() {
        let stickerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240)) // Adjust this height to fit your needs, this is the height of the sticker view
        stickerView.backgroundColor = .purple // Replace with your theme color or background image
        
        let doneButton = UIButton(frame: CGRect(x: stickerView.frame.width - 60, y: 10, width: 50, height: 30))
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        stickerView.addSubview(doneButton)

        // Add your stickers to the stickerView here

        stickerInputView = UIInputView(frame: stickerView.frame, inputViewStyle: .default)
        stickerInputView?.addSubview(stickerView)
        stickerInputView?.allowsSelfSizing = true
        self.messageInputBar.inputTextView.inputView = stickerInputView
    }

    @objc func didTapDone(button: UIButton) {
        self.messageInputBar.inputTextView.inputView = nil
        self.messageInputBar.inputTextView.reloadInputViews()
    }
}
