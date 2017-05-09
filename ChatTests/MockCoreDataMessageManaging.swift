//
//  MockCoreDataMessageManaging.swift
//  Chat
//
//  Created by Joshua Finch on 11/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation

@testable import Chat

class MockCoreDataMessageManaging: CoreDataMessageManaging {

    var onInsertOrUpdateMessageCalled: (() -> Void)?

    func insertOrUpdateMessage(message payload: MessagePayload, completion: @escaping () -> Void) {
        onInsertOrUpdateMessageCalled?()
    }
}
