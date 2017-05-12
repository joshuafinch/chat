//
//  ChatInputToolbar.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

class ChatInputToolbar: UIView {

    var onPressedSend: (() -> Void)?

    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    @IBAction func pressedSendButton(_ sender: Any) {
        onPressedSend?()
    }
}

extension ChatInputToolbar {

    static func view() -> Self {
        return Bundle.loadView(fromNib: "ChatInputToolbar", withType: self)
    }
}
