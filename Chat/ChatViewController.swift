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
            if let messagesView = messagesView {
                setup(messagesView: messagesView)
            }
        }
    }

    let messageCellReuseIdentifier = "MessageCell"

    private(set) var messagesView: MessagesView?

    private var toolbar: ChatInputToolbar?
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMessage))
        navigationItem.rightBarButtonItem = add
        
        return navigationItem
    }
    
    override func loadView() {

        automaticallyAdjustsScrollViewInsets = false

        view = UIView()
        view.backgroundColor = UIColor.blue

        let messagesView = MessagesView.view()
        messagesView.backgroundColor = UIColor.purple
        messagesView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagesView)

        let toolbar = ChatInputToolbar.view()
        toolbar.backgroundColor = UIColor.green
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)

        messagesView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messagesView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        messagesView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        messagesView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        toolbar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        setup(toolbar: toolbar)
        setup(messagesView: messagesView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(invalidateMessagesViewLayout), 
                                               name: Notification.Name.UIContentSizeCategoryDidChange, 
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)
    }

    private func setup(toolbar: ChatInputToolbar) {

        toolbar.onPressedSend = { [unowned self] text in
            self.onPressedSend(text: text)
        }

        self.toolbar = toolbar
    }

    private func setup(messagesView: MessagesView) {

        self.messagesView = messagesView

        guard let state = state else {
            self.messagesView?.state = nil
            return
        }

        messagesView.state = MessagesView.State(chatId: state.chatService.chatId,
                                                senderId: state.chatService.senderId,
                                                persistentContainer: state.persistentContainer)
    }

    // MARK:

    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        invalidateMessagesViewLayout()
    }

    func invalidateMessagesViewLayout() {
        messagesView?.collectionView.collectionViewLayout.invalidateLayout()
        messagesView?.collectionView.reloadData()
    }

    // MARK: Actions
    
    func addMessage() {

        guard let state = state else {
            preconditionFailure("State must not be nil to add a message")
        }

        state.chatService.receive(message: MessagePayload(id: NSUUID().uuidString,
                                                          chatId: "chatId",
                                                          senderId: "otherSenderId",
                                                          body: "Message from other: \(Date().timeIntervalSinceReferenceDate)",
                                                          timestamp: NSDate()))
    }

    // MARK: ChatInputToolbar

    func onPressedSend(text: String) {

        guard let state = state else {
            preconditionFailure("State must not be nil to send a message")
        }

        state.chatService.send(messageWithBody: text)
    }
}

extension ChatViewController: PersistentContainerChangeDelegate {

    func persistentContainerChanged(persistentContainer: NSPersistentContainer?) {
        state?.persistentContainer = persistentContainer
    }
}
