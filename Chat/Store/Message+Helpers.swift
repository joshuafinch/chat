//
//  Message+Helpers.swift
//  Chat
//
//  Created by Joshua Finch on 06/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

extension Message {

    class func entityName() -> String {
        return "Message"
    }
    
    class func insert(into context: NSManagedObjectContext) -> Message {
        return NSEntityDescription.insertNewObject(forEntityName: Message.entityName(), into: context) as! Message
    }
    
    @nonobjc class func fetchRequest(forMessagesWithChatId chatId: String) -> NSFetchRequest<Message> {
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
        
        let mostRecentMessageFirst = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [mostRecentMessageFirst]
        
        return fetchRequest
    }
    
    @nonobjc class func fetchRequest(forMessageWithIdentity identity: MessageIdentity) -> NSFetchRequest<Message> {
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        
        fetchRequest.predicate = identity.predicate
        fetchRequest.fetchLimit = 1
        
        let mostRecentMessageFirst = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [mostRecentMessageFirst]
        
        return fetchRequest
    }
    
}
