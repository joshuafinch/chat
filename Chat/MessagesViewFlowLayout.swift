//
//  MessagesViewFlowLayout.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

class MessagesViewFlowLayout: UICollectionViewFlowLayout {

    var insertingIndexPaths = Set<IndexPath>()

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        insertingIndexPaths.removeAll()

        for update in updateItems {
            if let indexPath = update.indexPathAfterUpdate, update.updateAction == .insert {
                insertingIndexPaths.insert(indexPath)
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        insertingIndexPaths.removeAll()
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

        if insertingIndexPaths.contains(itemIndexPath) {
            attributes?.alpha = 0
            attributes?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }

        return attributes
    }
}
