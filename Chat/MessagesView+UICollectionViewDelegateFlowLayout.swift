//
//  MessagesView+UICollectionViewDelegateFlowLayout.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

extension MessagesView: UICollectionViewDelegateFlowLayout {

    static var exampleTextView: UITextView {
        let cell = MessageCell()
        return cell.textView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let maxWidth = collectionView.bounds.size.width
        let exampleSize = CGSize(width: maxWidth, height: 1000.0)

        let textView = MessagesView.exampleTextView
        textView.text = self.message(atIndexPath: indexPath)?.body
        let height = textView.sizeThatFits(exampleSize).height

        return CGSize(width: maxWidth, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: collectionView.bounds.size.width, height: 50.0)
    }
}
