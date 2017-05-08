//
//  MessageImporter.swift
//  Chat
//
//  Created by Joshua Finch on 08/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

class MessageImporter {
    
    struct Message {
        let id: String
        let chatId: String
        let senderId: String
        let body: String?
        let timestamp: NSDate
    }
    
    private let queue: DispatchQueue
    private let persistentContainer: NSPersistentContainer
    
    init(label: String, persistentContainer: NSPersistentContainer) {
        self.queue = DispatchQueue(label: label)
        self.persistentContainer = persistentContainer
    }
    
    func importMessage(message: MessageImporter.Message, completion: (() -> ())? = nil) {
        
        queue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let group = DispatchGroup()
            group.enter()
            strongSelf.insertMessage(message: message,
                                     persistentContainer: strongSelf.persistentContainer,
                                     completion: {
                                        group.leave()
            })
            
            group.wait()
            
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        
    }
    
    // MARK: - Private
    
    private func insertMessage(message m: MessageImporter.Message,
                               persistentContainer: NSPersistentContainer,
                               completion: @escaping () -> ())
    {
        persistentContainer.performBackgroundTask({ (context) in
            
            defer { completion() }
            
            var message: Chat.Message? = self.find(message: m)
            
            if (message == nil) {
                message = Chat.Message.insert(into: context)
            }
            
            if let message = message {
                message.id = m.id
                message.chatId = m.chatId
                message.senderId = m.senderId
                message.body = m.body
                message.timestamp = m.timestamp as NSDate
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error {
                    print("Error saving: \(error)")
                }
            }
        })
    }
    
    private func find(message m: MessageImporter.Message) -> Chat.Message? {
        
        let fetchRequest = Chat.Message.message(messageId: m.id, senderId: m.senderId, chatId: m.chatId)
        
        do {
            return try fetchRequest.execute().first
        } catch let error {
            print("Fetch request error (find message): \(error)")
            return nil
        }
    }
}
