//
//  ChatViewController.swift
//  Chat
//
//  Created by Joshua Finch on 09/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class ChatViewController: UIViewController {

    struct State {
        let chatService: ChatServiceProtocol
        var persistentContainer: NSPersistentContainer?
    }

    var state: State? {
        didSet {
            setupFetchedResultsController()
        }
    }
    
    private(set) var tableView: UITableView?
    private(set) var fetchedResultsController: NSFetchedResultsController<Message>?
    
    struct Change {
        let type: NSFetchedResultsChangeType
        let sectionIndex: Int?
        let indexPath: IndexPath?
        let newIndexPath: IndexPath?
    }
    
    var changes: [Change] = []
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMessage))
        navigationItem.rightBarButtonItem = add
        
        return navigationItem
    }
    
    override func loadView() {
        
        view = UIView()
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.reloadData()
        
        self.tableView = tableView
    }
    
    // MARK: Actions
    
    func addMessage() {

        guard let state = state else {
            preconditionFailure("State must not be nil to add a message")
        }
        
        for _ in 0..<3 {
            state.chatService.sendMessage(body: "Message: \(Date().timeIntervalSinceReferenceDate)")
        }
    }

    // MARK: - Private

    private func setupFetchedResultsController() {
        guard let state = state, let persistentContainer = state.persistentContainer else {
            fetchedResultsController = nil
            tableView?.reloadData()
            return
        }

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: Message.fetchRequest(forMessagesWithChatId: state.chatService.chatId),
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            tableView?.reloadData()
        } catch let error {
            print("Error: \(error)")
        }
    }
}

extension ChatViewController: PersistentContainerChangeDelegate {

    func persistentContainerChanged(persistentContainer: NSPersistentContainer?) {
        state?.persistentContainer = persistentContainer
    }
}
