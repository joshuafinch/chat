//
//  MessagesView.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MessagesView: UIView {

    struct State {
        let chatId: String
        let senderId: String
        let persistentContainer: NSPersistentContainer?
    }

    var state: State? {
        didSet {
            setupFetchedResultsController()
        }
    }

    var changes: [FetchedResultsControllerChange] = []

    let messageCellReuseIdentifier = "MessageCell"
    let sectionHeaderReuseIdentifier = "MessageSectionHeader"

    private(set) var fetchedResultsController: NSFetchedResultsController<Message>?

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            setupCollectionView()
        }
    }

    // MARK: 

    var numberOfSections: Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    func numberOfObjects(inSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections, sections.count > section, section >= 0 else {
            return 0
        }
        return sections[section].numberOfObjects
    }

    func sectionIdentifier(atIndexPath indexPath: IndexPath) -> String? {
        guard let sections = fetchedResultsController?.sections, sections.count > indexPath.section, indexPath.section >= 0 else {
            return nil
        }
        return sections[indexPath.section].name
    }

    func message(atIndexPath indexPath: IndexPath) -> Message? {
        return fetchedResultsController?.object(at: indexPath)
    }

    func isOutgoing(message: Message) -> Bool {
        return message.senderId == state!.senderId
    }

    func scrollToBottom(animated: Bool, ignoringVisibilityOfLastMessage: Bool = false) {

        if let lastMessageIndexPath = lastMessageIndexPath() {

            var mostRecentMessageWasSentByCurrentUser = false

            if let mostRecentMessage = message(atIndexPath: lastMessageIndexPath), let state = state {
                if mostRecentMessage.senderId == state.senderId {
                    mostRecentMessageWasSentByCurrentUser = true
                }
            }

            let visibleItems = collectionView.indexPathsForVisibleItems
            if visibleItems.contains(lastMessageIndexPath) ||
                mostRecentMessageWasSentByCurrentUser ||
                ignoringVisibilityOfLastMessage {
                collectionView?.scrollToItem(at: lastMessageIndexPath, at: .bottom, animated: false)
            }
        }
    }

    // MARK:

    private func setupCollectionView() {

        let messageCellNib = UINib(nibName: "MessageCell", bundle: Bundle.main)
        collectionView.register(messageCellNib, forCellWithReuseIdentifier: messageCellReuseIdentifier)

        let messageSectionHeaderNib = UINib(nibName: "MessageSectionHeaderView", bundle: Bundle.main)
        collectionView.register(messageSectionHeaderNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: sectionHeaderReuseIdentifier)

        let navigationBarInset: CGFloat = 64.0
        let toolBarInset: CGFloat = 50.0

        let inset = UIEdgeInsetsMake(navigationBarInset, 0, toolBarInset, 0)
        collectionView.contentInset = inset
        collectionView.scrollIndicatorInsets = inset

        collectionView.collectionViewLayout = MessagesViewFlowLayout()
    }

    private func setupFetchedResultsController() {
        guard let state = state, let persistentContainer = state.persistentContainer else {
            fetchedResultsController = nil
            collectionView?.reloadData()
            scrollToBottom(animated: false, ignoringVisibilityOfLastMessage: true)
            return
        }

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Message.fetchRequest(forMessagesWithChatId: state.chatId),
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: Message.Constants.sectionIdentifier.rawValue,
            cacheName: nil)

        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            collectionView?.reloadData()
            scrollToBottom(animated: false, ignoringVisibilityOfLastMessage: true)
        } catch let error {
            print("Error: \(error)")
        }
    }

    private func lastMessageIndexPath() -> IndexPath? {
        guard numberOfSections > 0 else {
            return nil
        }

        let lastSection = numberOfSections - 1
        let numberOfMessages = numberOfObjects(inSection: lastSection)
        guard numberOfMessages > 0 else {
            return nil
        }

        return IndexPath(item: numberOfMessages - 1, section: lastSection)
    }
}

extension MessagesView {

    static func view() -> Self {
        return Bundle.loadView(fromNib: "MessagesView", withType: self)
    }
}
