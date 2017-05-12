//
//  MessageCell.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundColor = UIColor.white
        label.text = nil
    }

    func configure(withMessage message: Message, isOutgoing: Bool) {
        backgroundColor = isOutgoing ? UIColor.cyan : UIColor.green
        label.text = message.body
    }
}
