//
//  MessageSectionHeaderView.swift
//  Chat
//
//  Created by Joshua Finch on 14/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

class MessageSectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var label: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        label.text = nil
    }

    private static let fromSectionIdentifierDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter
    }()

    private static let toSectionNameFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EdMMM", options: 0, locale: Locale.current)
        return dateFormatter
    }()

    func configure(withSectionIdentifier sectionIdentifier: String?) {
        label.text = userVisibleDate(fromSectionIdentifier: sectionIdentifier)
    }

    private func userVisibleDate(fromSectionIdentifier sectionIdentifier: String?) -> String? {
        guard let sectionIdentifier = sectionIdentifier else {
            return nil
        }

        guard let date = MessageSectionHeaderView.fromSectionIdentifierDateFormatter.date(from: sectionIdentifier) else {
            return nil
        }

        return MessageSectionHeaderView.toSectionNameFormatter.string(from: date)
    }
}
