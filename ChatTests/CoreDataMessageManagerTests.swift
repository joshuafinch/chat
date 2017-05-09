//
//  CoreDataMessageManagerTests.swift
//  Chat
//
//  Created by Joshua Finch on 11/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable import Chat

class CoreDataMessageManagerTests: XCTestCase {

    private var coreData: CoreData?
    private var persistentContainer: NSPersistentContainer?
    private var coreDataMessageManager: CoreDataMessageManager?

    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let expect = expectation(description: "Persistent stores loaded successfully")

        coreData = CoreData(name: "Model", storeType: .InMemory, loadPersistentStoresCompletionHandler: { success in
            expect.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertNotNil(coreData)
        persistentContainer = coreData!.persistentContainer
        XCTAssertNotNil(persistentContainer)

        coreDataMessageManager = CoreDataMessageManager(persistentContainer: persistentContainer!)
        XCTAssertNotNil(coreDataMessageManager)
    }

    func testInsertOrUpdateMessage_InsertsNewMessage() {

        let id = "id"
        let chatId = "chatId"
        let senderId = "senderId"
        let body = "body"
        let timestamp = NSDate()

        let message = MessagePayload(id: id, chatId: chatId, senderId: senderId, body: body, timestamp: timestamp)

        let expect = expectation(description: "inserts message")

        coreDataMessageManager!.insertOrUpdateMessage(message: message) { 
            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        do {
            let messages: [Message] = try persistentContainer!.viewContext.fetch(Message.fetchRequest())
            XCTAssert(messages.count == 1, "Message count should be 1, was \(messages.count)")
            XCTAssertNotNil(messages.first)
            XCTAssert(messages.first!.body == "body")
            XCTAssert(messages.first!.timestamp == timestamp)
        } catch let error {
            XCTFail("Error fetching messages: \(error)")
        }
    }

    func testInsertOrUpdateMessage_UpdatesExistingMessage() {
        let timestamp1 = NSDate()
        let timestamp2 = NSDate().addingTimeInterval(3.0)

        let m = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body", timestamp: timestamp1)
        let m2 = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body2", timestamp: timestamp2)

        let expect = expectation(description: "inserts or updates both messages")
        expect.expectedFulfillmentCount = 2

        let g = DispatchGroup()

        g.enter()
        coreDataMessageManager!.insertOrUpdateMessage(message: m, completion: {
            expect.fulfill()
            g.leave()
        })

        g.wait()

        g.enter()
        coreDataMessageManager!.insertOrUpdateMessage(message: m2, completion: {
            expect.fulfill()
            g.leave()
        })

        g.wait()

        waitForExpectations(timeout: 1.0, handler: nil)

        do {
            let messages: [Message] = try persistentContainer!.viewContext.fetch(Message.fetchRequest())
            XCTAssert(messages.count == 1, "Message count should be 1, was \(messages.count)")
            XCTAssertNotNil(messages.first)
            XCTAssert(messages.first!.body == "body2")
            XCTAssert(messages.first!.timestamp == timestamp2)
        } catch let error {
            XCTFail("Error fetching messages: \(error)")
        }
    }
}
