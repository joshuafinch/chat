//
//  ChatViewController+NSFetchedResultsControllerDelegate.swift
//  Chat
//
//  Created by Joshua Finch on 09/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import UIKit
import CoreData

struct FetchedResultsControllerChange {
    let type: NSFetchedResultsChangeType
    let sectionIndex: Int?
    let indexPath: IndexPath?
    let newIndexPath: IndexPath?
}
