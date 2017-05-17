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
    private var toolbarBottomConstraint: NSLayoutConstraint?
    
//    override var navigationItem: UINavigationItem {
//        let navigationItem = super.navigationItem
//        
//
//        
//        return navigationItem
//    }

    override func loadView() {

        automaticallyAdjustsScrollViewInsets = false

        title = "Chat"

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
        toolbarBottomConstraint = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        toolbarBottomConstraint?.isActive = true
        toolbar.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        setup(toolbar: toolbar)
        setup(messagesView: messagesView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMessage))
        navigationItem.rightBarButtonItem = add
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(invalidateMessagesViewLayout), 
                                               name: Notification.Name.UIContentSizeCategoryDidChange, 
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: Notification.Name.UIKeyboardDidShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidHide),
                                               name: Notification.Name.UIKeyboardDidHide,
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

    // MARK: Notification Observers

    func invalidateMessagesViewLayout() {
        messagesView?.collectionView.collectionViewLayout.invalidateLayout()
        messagesView?.collectionView.reloadData()
    }

    func keyboardWillHide(notification: Notification) {
        handleKeyboard(notification: notification)
    }

    func keyboardDidHide(notification: Notification) {

    }

    func keyboardWillShow(notification: Notification) {
        handleKeyboard(notification: notification)
    }

    func keyboardDidShow(notification: Notification) {

    }

    private func handleKeyboard(notification: Notification) {
        guard let info = notification.userInfo else {
            return
        }

        guard let endFrame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let beginFrame = info[UIKeyboardFrameBeginUserInfoKey] as? CGRect,
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curve = info[UIKeyboardAnimationCurveUserInfoKey] as? Int else {
            return
        }

        let previousKeyboardHeight = toolbarBottomConstraint!.constant

        let keyboardRect = view.convert(endFrame, from: nil)
        let viewHeight = view.bounds.height
        let keyboardMinY = keyboardRect.minY
        let keyboardHeight = max(0.0, viewHeight - keyboardMinY)

        if (beginFrame != endFrame || fabs(previousKeyboardHeight - toolbarBottomConstraint!.constant) > 0.0)
        {
            self.view.layoutIfNeeded()

            let options = UIViewAnimationOptions(rawValue: UInt(curve << 16)).union([.beginFromCurrentState, .layoutSubviews])

            self.toolbarBottomConstraint!.constant = -keyboardHeight

            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
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
