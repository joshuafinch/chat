//
//  CoreDataMessageManager.swift
//  Chat
//
//  Created by Joshua Finch on 11/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataMessageManaging: class {

    /**
     Inserts new, or updates an existing message using the `payload`

     - parameter payload: The message to insert, or update existing with
     - parameter completion: Called once, after the message has been inserted, or updated
     */
    func insertOrUpdateMessage(message payload: MessagePayload,
                               completion: @escaping () -> Void)
}

final class CoreDataMessageManager: CoreDataMessageManaging {

    fileprivate var persistentContainer: NSPersistentContainer?

    init(persistentContainer: NSPersistentContainer?) {
        self.persistentContainer = persistentContainer
    }

    // MARK: - CoreDataMessageManaging

    func insertOrUpdateMessage(message payload: MessagePayload, completion: @escaping () -> Void) {

        persistentContainer?.performBackgroundTask({ [weak self] (context) in

            defer { completion() }

            guard let strongSelf = self else {
                return
            }

            var message = strongSelf.find(messageForIdentity: payload.identity)

            if message == nil {
                message = Message.insert(into: context)
            }

            if let message = message {
                message.id = payload.id
                message.chatId = payload.chatId
                message.senderId = payload.senderId
                message.body = payload.body
                message.timestamp = payload.timestamp

                if context.hasChanges {
                    do {
                        try context.save()
                    } catch let error {
                        print("Error saving: \(error)")
                    }
                }
            }
        })
    }

    func deleteMessage(identity: MessageIdentity, completion: @escaping () -> Void) {

        persistentContainer?.performBackgroundTask { [weak self] (context) in

            defer { completion() }

            guard let strongSelf = self else {
                return
            }

            if let message = strongSelf.find(messageForIdentity: identity) {
                context.delete(message)

                do {
                    try context.save()
                } catch let error {
                    print("Error saving: \(error)")
                }
            }
        }
    }

    // MARK: - Private

    /**
     Executes a fetch request on the current queue to find a single message
     matching by `id`, `senderId`, and `chatId`

     - parameter id: The `id` of the message to find
     - parameter senderId: The `senderId` of the message to find
     - parameter chatId: The `chatId` of the message to find
     - returns: Message if found, `nil` otherwise

     */
    private func find(messageForIdentity identity: MessageIdentity) -> Message? {

        let fetchRequest = Message.fetchRequest(forMessageWithIdentity: identity)

        do {
            return try fetchRequest.execute().first
        } catch let error {
            print("Fetch request error (find message): \(error)")
            return nil
        }
    }
}

extension CoreDataMessageManager: PersistentContainerChangeDelegate {

    func persistentContainerChanged(persistentContainer: NSPersistentContainer?) {
        self.persistentContainer = persistentContainer
    }
}
