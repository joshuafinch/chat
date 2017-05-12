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

    func send(messageWithBody body: String)

    func receive(message: MessagePayload)
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
    
    func send(messageWithBody body: String) {

        let message = MessagePayload(id: NSUUID().uuidString,
                                     chatId: chatId,
                                     senderId: senderId,
                                     body: body,
                                     timestamp: NSDate())
        
        messageImporter.importMessage(message: message, completion: nil)
    }

    func receive(message: MessagePayload) {

        messageImporter.importMessage(message: message, completion: nil)
    }
}
