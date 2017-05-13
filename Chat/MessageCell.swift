//
//  MessageCell.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

class UIUnselectableTextView: UITextView {

    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if let longPressGestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
            if longPressGestureRecognizer.minimumPressDuration < 0.3 {
                super.addGestureRecognizer(gestureRecognizer)
            }
        } else if let tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer {
            if tapGestureRecognizer.numberOfTapsRequired == 1 {
                super.addGestureRecognizer(gestureRecognizer)
            }
        }
    }
}

class MessageCell: UICollectionViewCell {

    var textView: UIUnselectableTextView = {
        let textView = UIUnselectableTextView()
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.dataDetectorTypes = [.link, .phoneNumber]

        textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8)

        textView.adjustsFontForContentSizeCategory = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)

        textView.layer.cornerRadius = 16.0
        textView.layer.masksToBounds = true

        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.addSubview(textView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text = nil
    }

    func configure(withMessage message: Message, isOutgoing: Bool) {

        textView.backgroundColor = isOutgoing ? UIColor.cyan : UIColor.green
        textView.text = message.body

        let size = CGSize(width: self.bounds.size.width, height: 1000.0)
        textView.frame = CGRect(origin: .zero, size: textView.sizeThatFits(size))
    }
}
