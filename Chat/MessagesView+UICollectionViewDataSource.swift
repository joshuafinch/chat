//
//  MessagesView+UICollectionViewDataSource.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

extension MessagesView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfObjects(inSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellReuseIdentifier, for: indexPath) as! MessageCell

        if let message = message(atIndexPath: indexPath) {
            cell.configure(withMessage: message, isOutgoing: isOutgoing(message: message))
        }

        return cell
    }
}
