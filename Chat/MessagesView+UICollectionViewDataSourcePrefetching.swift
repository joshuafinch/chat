//
//  MessagesView+UICollectionViewDataSourcePrefetching.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

extension MessagesView: UICollectionViewDataSourcePrefetching {

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}
