//
//  MessagePayload.swift
//  Chat
//
//  Created by Joshua Finch on 11/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation

struct MessageIdentity {
    let id: String
    let chatId: String
    let senderId: String

    var predicate: NSPredicate {
        return NSPredicate(format: "id == %@ AND chatId == %@ AND senderId == %@", id, chatId, senderId)
    }
}

struct MessagePayload {

    let identity: MessageIdentity
    let body: String?
    let timestamp: NSDate

    var id: String {
        return identity.id
    }

    var chatId: String {
        return identity.chatId
    }

    var senderId: String {
        return identity.senderId
    }

    init(identity: MessageIdentity, body: String?, timestamp: NSDate) {
        self.identity = identity
        self.body = body
        self.timestamp = timestamp
    }

    init(id: String, chatId: String, senderId: String, body: String?, timestamp: NSDate) {
        self.init(identity: MessageIdentity(id: id, chatId: chatId, senderId: senderId), body: body, timestamp: timestamp)
    }
}
