//
//  ChatService.swift
//  Chat
//
//  Created by Joshua Finch on 09/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation

protocol ChatServiceProtocol {

    var chatId: String { get }
    var senderId: String { get }

    func sendMessage(body: String)
}

final class ChatService: ChatServiceProtocol {
    
    private let messageImporter: MessageImporting

    let chatId: String
    let senderId: String

    init(chatId: String, senderId: String, messageImporter: MessageImporting) {
        self.chatId = chatId
        self.senderId = senderId

        self.messageImporter = messageImporter
    }
    
    func sendMessage(body: String) {

        let message = MessagePayload(id: NSUUID().uuidString,
                                     chatId: chatId,
                                     senderId: senderId,
                                     body: body,
                                     timestamp: NSDate())
        
        messageImporter.importMessage(message: message, completion: nil)
    }
}
