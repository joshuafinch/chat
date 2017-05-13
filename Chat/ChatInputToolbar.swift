//
//  ChatInputToolbar.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

class ChatInputViewModel {

    struct State {
        let sendButtonIsEnabled: Bool
        let shouldClearInputTextFieldText: Bool
    }

    var state: State = ChatInputViewModel.emptyState {
        didSet {
            callback(state)
        }
    }

    private static let emptyState = State(sendButtonIsEnabled: false, shouldClearInputTextFieldText: true)

    var callback: (State) -> Void

    init(_ callback: @escaping (State) -> Void) {
        self.callback = callback
        self.callback(state)
    }

    func sendButtonPressed() {
        state = ChatInputViewModel.emptyState
    }
}

class ChatInputToolbar: UIView {

    static let maxCharacters: Int = 5000

    var onPressedSend: ((String) -> Void)?

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    fileprivate var viewModel: ChatInputViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()

        viewModel = ChatInputViewModel { [unowned self] (state) in
            if state.shouldClearInputTextFieldText {
                self.inputTextField.text = nil
            }
            self.sendButton.isEnabled = state.sendButtonIsEnabled
        }
    }

    @IBAction func pressedSendButton(_ sender: Any) {

        let trimmedText = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        viewModel.sendButtonPressed()

        guard let text = trimmedText, text.characters.count > 0 else {
            return
        }

        onPressedSend?(text)
    }
}

extension ChatInputToolbar: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentCharacterCount = textField.text?.characters.count ?? 0

        // Prevent crashing undo bug
        if range.length + range.location > ChatInputToolbar.maxCharacters {
            return false
        }

        let changedTextCharacterCount = currentCharacterCount + (string.characters.count - range.length)
        let hasAcceptableCharacterCount = changedTextCharacterCount <= ChatInputToolbar.maxCharacters

        if !hasAcceptableCharacterCount {
            return false
        }

        let sendButtonIsEnabled = changedTextCharacterCount > 0
        viewModel.state = .init(sendButtonIsEnabled: sendButtonIsEnabled, shouldClearInputTextFieldText: false)
        return true
    }
}

extension ChatInputToolbar {

    static func view() -> Self {
        return Bundle.loadView(fromNib: "ChatInputToolbar", withType: self)
    }
}
