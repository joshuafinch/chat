//
//  MessagesView+NSFetchedResultsControllerDelegate.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

extension MessagesView: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.changes = []
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType)
    {
        let change = FetchedResultsControllerChange(type: type,
                                                    sectionIndex: sectionIndex,
                                                    indexPath: nil,
                                                    newIndexPath: nil)
        self.changes.append(change)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
    {
        let change = FetchedResultsControllerChange(type: type,
                                                    sectionIndex: nil,
                                                    indexPath: indexPath,
                                                    newIndexPath: newIndexPath)
        self.changes.append(change)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        handle(fetchedResultsControllerChanges: self.changes)
    }

    func handle(fetchedResultsControllerChanges changes: [FetchedResultsControllerChange]) {

        guard let collectionView = self.collectionView else {
            return
        }

        var didInsertNewMessage = false

        collectionView.performBatchUpdates({

            for change in changes {
                if let sectionIndex = change.sectionIndex {
                    switch change.type {
                    case .delete:
                        collectionView.deleteSections([sectionIndex])
                    case .insert:
                        collectionView.insertSections([sectionIndex])
                    case .move:
                        break
                    case .update:
                        collectionView.reloadSections([sectionIndex])
                    }
                } else {
                    switch change.type {
                    case .delete:
                        collectionView.deleteItems(at: [change.indexPath!])

                    case .insert:
                        collectionView.insertItems(at: [change.newIndexPath!])
                        didInsertNewMessage = true

                    case .move:
                        collectionView.deleteItems(at: [change.indexPath!])
                        collectionView.insertItems(at: [change.newIndexPath!])

                    case .update:
                        collectionView.reloadItems(at: [change.indexPath!])
                    }
                }
            }

        }, completion: nil)

        if didInsertNewMessage {
            scrollToBottom(animated: true)
        }
    }
}
