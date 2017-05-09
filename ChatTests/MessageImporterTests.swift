//
//  MessageImporterTests.swift
//  Chat
//
//  Created by Joshua Finch on 06/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import XCTest

@testable import Chat

class MessageImporterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testImportMessage_Calls_CoreDataMessageManaging_InsertOrUpdateMessage() {
        
        let m = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId",
                               body: "body", timestamp: NSDate())
        
        let expect = expectation(description: "insertOrUpdateMessage called")

        let coreDataMessageManager = MockCoreDataMessageManaging()
        coreDataMessageManager.onInsertOrUpdateMessageCalled = {
            expect.fulfill()
        }

        let messageImporter = MessageImporter(label: NSUUID().uuidString, coreDataMessageManager: coreDataMessageManager)

        messageImporter.importMessage(message: m, completion: nil)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testImportMultipleMessagesIsExecutedInSeries() {

        // The message payload `id` refers to the milliseconds before importMessage's completion is
        // called for the test double we're using.
        //
        // This allows us to ensure an import that takes 300 milliseconds that's executed first
        // will call its completion handler first.
        //
        // Any other imports that are executed during those 300 milliseconds will be queued to
        // execute after (in-order)

        let m = MessagePayload(id: "100", chatId: "chatId", senderId: "senderId",
                               body: "body", timestamp: NSDate())
        let m2 = MessagePayload(id: "200", chatId: "chatId", senderId: "senderId",
                                body: "body", timestamp: NSDate())
        let m3 = MessagePayload(id: "300", chatId: "chatId", senderId: "senderId",
                                body: "body", timestamp: NSDate())

        var completionCallCount = 0

        let q = DispatchQueue(label: "testMultipleMessagesAreImportedInSeries.completionCallCount.accessQueue")

        let expectFirstMessage = expectation(description: "First message completed, first")
        let expectSecondMessage = expectation(description: "Second message completed, second")
        let expectThirdMessage = expectation(description: "Third message completed, third")

        expectFirstMessage.expectedFulfillmentCount = 1
        expectFirstMessage.assertForOverFulfill = true

        let coreDataMessageManager = CoreDataMessageManagerDouble()
        let messageImporter = MessageImporter(label: NSUUID().uuidString, coreDataMessageManager: coreDataMessageManager)

        messageImporter.importMessage(message: m3) {
            q.async {
                completionCallCount += 1
                if completionCallCount == 1 {
                    expectFirstMessage.fulfill()
                } else {
                    XCTFail("First message should have its completion callback called first")
                }
            }
        }

        messageImporter.importMessage(message: m) {
            q.async {
                completionCallCount += 1
                if completionCallCount == 2 {
                    expectSecondMessage.fulfill()
                } else {
                    XCTFail("Second message should have its completion callback called second")
                }
            }
        }

        messageImporter.importMessage(message: m2) {
            q.async {
                completionCallCount += 1
                if completionCallCount == 3 {
                    expectThirdMessage.fulfill()
                } else {
                    XCTFail("Third message should have its completion callback called third")
                }
            }
        }

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}

// MARK: -

fileprivate class CoreDataMessageManagerDouble: CoreDataMessageManaging {

    func insertOrUpdateMessage(message payload: MessagePayload, completion: @escaping () -> Void) {

        // This test double uses the `payload.id` to increase the time before `completion` is called

        let millis = Int(payload.id)!
        let afterTime: DispatchTime = .now() + .milliseconds(millis)
        print("dispatch after: \(afterTime)")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: afterTime) {
            completion()
        }
    }
}
