//
//  MessageImporter.swift
//  Chat
//
//  Created by Joshua Finch on 08/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

protocol MessageImporting {

    /**
     Imports a message, usually into a persistent store
     
     - parameter message: The message which should be imported
     - parameter completion: Called once, after the message has been imported
    */
    func importMessage(message: MessagePayload, completion: (() -> Void)?)
}

/**
 Asynchronously imports messages on a `DispatchQueue` serially to ensure there are no problems with duplicate imported messages

 */
final class MessageImporter: MessageImporting {
    
    private let queue: DispatchQueue
    private let coreDataMessageManager: CoreDataMessageManaging
    
    init(label: String, coreDataMessageManager: CoreDataMessageManaging) {
        self.queue = DispatchQueue(label: label)
        self.coreDataMessageManager = coreDataMessageManager
    }
    
    func importMessage(message: MessagePayload, completion: (() -> Void)? = nil) {
        
        queue.async { [weak coreDataMessageManager] in

            defer {
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }

            guard let coreDataMessageManager = coreDataMessageManager else {
                return
            }
            
            let group = DispatchGroup()
            group.enter()

            coreDataMessageManager.insertOrUpdateMessage(message: message, completion: {
                group.leave()
            })
            
            group.wait()
        }
        
    }
}
