//
//  Message+CoreDataProperties.swift
//  Chat
//
//  Created by Sam Gaus on 06/05/2017.
//  Copyright © 2017 Sam Gaus. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var id: String?
    @NSManaged public var body: String?
    @NSManaged public var senderId: String?
    @NSManaged public var chatId: String?
    @NSManaged public var timestamp: NSDate?

}
