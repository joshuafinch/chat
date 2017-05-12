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

    private var toolbar: ChatInputToolbar?
    
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

        automaticallyAdjustsScrollViewInsets = false

        view = UIView()
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        let toolbar = ChatInputToolbar.view()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        // Invert the table view so that new messages appear at the bottom
        // We also must do the same for any dequeued table view cells so that they don't appear upside-down
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)

        // Inset the table view content and scroll indicator so that it doesn't go under the navigation bar
        let insets = UIEdgeInsetsMake(0, 0, 64, 0)
        tableView.scrollIndicatorInsets = insets
        tableView.contentInset = insets

        toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toolbar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        setupToolbar(toolbar: toolbar)
        setupTableView(tableView: tableView)
    }

    private func setupToolbar(toolbar: ChatInputToolbar) {

        toolbar.onPressedSend = { [weak self] in
            self?.onPressedSend()
        }

        self.toolbar = toolbar
    }

    private func setupTableView(tableView: UITableView) {
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

    // MARK: ChatInputToolbar

    func onPressedSend() {

        guard let state = state else {
            preconditionFailure("State must not be nil to send a message")
        }

        guard let messageBody = self.toolbar?.inputTextField?.text else {
            return
        }

        state.chatService.sendMessage(body: messageBody)
        self.toolbar?.inputTextField?.text = nil
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
