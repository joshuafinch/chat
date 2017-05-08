//
//  MessageTests.swift
//  Chat
//
//  Created by Joshua Finch on 06/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import XCTest

import CoreData

@testable import Chat

class MessageImporterTests: XCTestCase {
    
    private var coreData: CoreData?
    private var messageImporter: MessageImporter?
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        
        let expect = expectation(description: "Persistent stores loaded successfully")
        
        coreData = CoreData(name: "Model", storeType: .InMemory, loadPersistentStoresCompletionHandler: { success in
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
     
        guard let persistentContainer = coreData?.persistentContainer else {
            return
        }
        
        messageImporter = MessageImporter(label: NSUUID().uuidString, persistentContainer: persistentContainer)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInsertSingleMessage() {
        
        guard let coreData = coreData,
            let persistentContainer = coreData.persistentContainer, 
            let messageImporter = messageImporter else
        {
            XCTFail("Unit test was not setup correctly")
            return
        }
        
        let timestamp = NSDate()
        
        let m = MessageImporter.Message(id: "id", chatId: "chatId", senderId: "senderId",
                                        body: "body", timestamp: timestamp)
        
        let expect = expectation(description: "imported message")
        
        messageImporter.importMessage(message: m, completion: {
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        do {
            let messages: [Message] = try persistentContainer.viewContext.fetch(Message.fetchRequest())
            XCTAssert(messages.count == 1, "Message count should be 1, was \(messages.count)")
            XCTAssertNotNil(messages.first)
            XCTAssert(messages.first!.body == "body")
            XCTAssert(messages.first!.timestamp == timestamp)
        } catch let error {
            XCTFail("Error fetching messages: \(error)")
        }
    }
    
    func testInsertSameMessageTwiceInSerialQueueUpdatesMessage() {
        
        guard let coreData = coreData,
            let persistentContainer = coreData.persistentContainer,
            let messageImporter = messageImporter else
        {
            XCTFail("Unit test was not setup correctly")
            return
        }
        
        let timestamp1 = NSDate()
        let timestamp2 = NSDate().addingTimeInterval(3.0)
        
        let m = MessageImporter.Message(id: "id", chatId: "chatId", senderId: "senderId",
                                        body: "body", timestamp: timestamp1)
        
        let m2 = MessageImporter.Message(id: "id", chatId: "chatId", senderId: "senderId",
                                         body: "body2", timestamp: timestamp2)
        
        let expect = expectation(description: "completed import of both messages")
        expect.expectedFulfillmentCount = 2
        
        messageImporter.importMessage(message: m, completion: {
            expect.fulfill()
        })
        
        messageImporter.importMessage(message: m2, completion: {
            expect.fulfill()
        })
    
        waitForExpectations(timeout: 1.0, handler: nil)
        
        do {
            let messages: [Message] = try persistentContainer.viewContext.fetch(Message.fetchRequest())
            XCTAssert(messages.count == 1, "Message count should be 1, was \(messages.count)")
            XCTAssertNotNil(messages.first)
            XCTAssert(messages.first!.body == "body2")
            XCTAssert(messages.first!.timestamp == timestamp2)
        } catch let error {
            XCTFail("Error fetching messages: \(error)")
        }
    }
    
    func testInsertDifferentMessagesInSerialQueueInsertsDifferentMessages() {
        
        guard let coreData = coreData,
            let persistentContainer = coreData.persistentContainer,
            let messageImporter = messageImporter else
        {
            XCTFail("Unit test was not setup correctly")
            return
        }
        
        let timestamp1 = NSDate()
        let timestamp2 = NSDate().addingTimeInterval(3.0)
        
        let m = MessageImporter.Message(id: "id", chatId: "chatId", senderId: "senderId",
                                        body: "body", timestamp: timestamp1)
        
        let m2 = MessageImporter.Message(id: "id2", chatId: "chatId", senderId: "senderId",
                                         body: "body2", timestamp: timestamp2)
        
        let expect = expectation(description: "completed import of both messages")
        expect.expectedFulfillmentCount = 2
        
        messageImporter.importMessage(message: m, completion: {
            expect.fulfill()
        })
        
        messageImporter.importMessage(message: m2, completion: {
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        do {
            let messages: [Message] = try persistentContainer.viewContext.fetch(Message.messagesInChat(chatId: "chatId"))
            XCTAssert(messages.count == 2, "Message count should be 2, was \(messages.count)")

            let firstMessage = messages[0]
            let secondMessage = messages[1]
            
            XCTAssert(firstMessage.body == "body2")
            XCTAssert(firstMessage.timestamp == timestamp2) // Most recent message first
            
            XCTAssert(secondMessage.body == "body")
            XCTAssert(secondMessage.timestamp == timestamp1) // Oldest message last
            
        } catch let error {
            XCTFail("Error fetching messages: \(error)")
        }
    }
}
