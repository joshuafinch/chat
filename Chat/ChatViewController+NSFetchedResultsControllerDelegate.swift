//
//  ChatViewController+NSFetchedResultsControllerDelegate.swift
//  Chat
//
//  Created by Joshua Finch on 09/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import UIKit
import CoreData

extension ChatViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
     
        self.changes = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType)
    {
        self.changes.append(Change(type: type, sectionIndex: sectionIndex, indexPath: nil, newIndexPath: nil))
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?)
    {
        self.changes.append(Change(type: type, sectionIndex: nil, indexPath: indexPath, newIndexPath: newIndexPath))
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        guard let tableView = self.tableView else {
            return
        }
        
        let block = {
            
            tableView.beginUpdates()
            
            var offsetY: CGFloat = 0
            
            for change in self.changes {
                if let sectionIndex = change.sectionIndex {
                    switch change.type {
                    case .delete:
                        tableView.deleteSections([sectionIndex], with: .none)
                    case .insert:
                        tableView.insertSections([sectionIndex], with: .none)
                    case .move:
                        break
                    case .update:
                        tableView.reloadSections([sectionIndex], with: .none)
                    }
                } else {
                    switch change.type {
                    case .delete:
                        tableView.deleteRows(at: [change.indexPath!], with: .none)
                        offsetY -= self.tableView(tableView, heightForRowAt: change.indexPath!)
                        
                    case .insert:
                        tableView.insertRows(at: [change.newIndexPath!], with: .none)
                        offsetY += self.tableView(tableView, heightForRowAt: change.newIndexPath!)
                        
                    case .move:
                        tableView.deleteRows(at: [change.indexPath!], with: .none)
                        offsetY -= self.tableView(tableView, heightForRowAt: change.indexPath!)
                        
                        tableView.insertRows(at: [change.newIndexPath!], with: .none)
                        offsetY += self.tableView(tableView, heightForRowAt: change.newIndexPath!)
                        
                    case .update:
                        tableView.reloadRows(at: [change.indexPath!], with: .none)
                        // TODO: Figure out a way to calculate height change between old and new for this reloaded row
                    }
                }
            }
            
            let originalContentOffset = tableView.contentOffset
            let newContentOffset = CGPoint(x: originalContentOffset.x, y: originalContentOffset.y + offsetY)
            tableView.contentOffset = newContentOffset
            
            tableView.endUpdates()
        }
        
        UIView.performWithoutAnimation(block)
    }
}
