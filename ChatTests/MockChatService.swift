//
//  MockChatService.swift
//  Chat
//
//  Created by Joshua Finch on 13/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation

@testable import Chat

struct MockChatService: ChatServiceProtocol {

    let chatId: String
    let senderId: String

    func send(messageWithBody body: String) {

    }

    func receive(message: MessagePayload) {
        
    }
}
