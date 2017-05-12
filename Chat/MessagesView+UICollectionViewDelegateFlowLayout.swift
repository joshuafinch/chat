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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let maxWidth = collectionView.bounds.size.width

        return CGSize(width: maxWidth, height: 50.0)
    }
}
