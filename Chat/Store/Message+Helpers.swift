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

    public class func entityName() -> String {
        return "Message"
    }
    
    public class func insert(into context: NSManagedObjectContext) -> Message {
        return NSEntityDescription.insertNewObject(forEntityName: Message.entityName(), into: context) as! Message
    }
    
    @nonobjc public class func messagesInChat(chatId: String) -> NSFetchRequest<Message> {
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "chatId == %@", chatId)
        
        let mostRecentMessageFirst = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [mostRecentMessageFirst]
        
        return fetchRequest
    }
    
    @nonobjc public class func message(messageId: String, senderId: String, chatId: String) -> NSFetchRequest<Message> {
        
        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND chatId == %@ AND senderId == %@",
                                             messageId, chatId, senderId)
        fetchRequest.fetchLimit = 1
        
        let mostRecentMessageFirst = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [mostRecentMessageFirst]
        
        return fetchRequest
    }
    
}
