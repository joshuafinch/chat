//
//  ChatViewControllerTests.swift
//  Chat
//
//  Created by Joshua Finch on 11/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable import Chat

class ChatViewControllerTests: XCTestCase {

    var chatViewController: ChatViewController!
    var coreData: CoreData!
    var persistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()

        chatViewController = ChatViewController()
        XCTAssertNil(chatViewController.state)
        XCTAssertNotNil(chatViewController.view)
        XCTAssertNotNil(chatViewController.tableView)

        let expect = expectation(description: "Loads in memory persistent stores successfully")

        coreData = CoreData(name: "Model", storeType: .InMemory, loadPersistentStoresCompletionHandler: { success in
            if success {
                expect.fulfill()
            } else {
                XCTFail("Could not load persistent stores successfully")
            }
        })

        waitForExpectations(timeout: 1.0, handler: nil)
        XCTAssertNotNil(coreData.persistentContainer)
        self.persistentContainer = coreData.persistentContainer

        let chatService = MockChatService(chatId: "chatId", senderId: "senderId")
        chatViewController.state = ChatViewController.State(chatService: chatService, persistentContainer: coreData.persistentContainer!)

        XCTAssertNotNil(chatViewController.fetchedResultsController)
        XCTAssertNotNil(chatViewController.fetchedResultsController!.delegate)
        XCTAssert(chatViewController.fetchedResultsController!.delegate! === chatViewController)
    }

    // MARK: -

    func testViewControllerWithoutState_IsConfiguredCorrectly() {

        let chatViewController = ChatViewController()
        XCTAssertNil(chatViewController.state)
        XCTAssertNotNil(chatViewController.view)
        XCTAssertNotNil(chatViewController.tableView)
    }

    func testViewControllerWithState_SetsUpFetchedRequestController() {
        let _ = chatViewController!
    }

    func testViewControllerWithState_ResetsFetchedRequestController_WhenStateIsSetToNil() {
        let vc = chatViewController!
        vc.state = nil

        XCTAssertNil(vc.fetchedResultsController)
    }

    // MARK: -

    func testInsertedMessageUpdatesTableView() {

        let vc = chatViewController!
        let tableView = vc.tableView!

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)

        let messageManager = CoreDataMessageManager(persistentContainer: persistentContainer)

        let expectInsertFirstMessage = expectation(description: "Inserted first message")
        let message = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: message) { 
            expectInsertFirstMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
    }

    func testInsertedSecondMessageUpdatesTableViewAgain() {

        let vc = chatViewController!
        let tableView = vc.tableView!

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)

        let messageManager = CoreDataMessageManager(persistentContainer: persistentContainer)

        let expectInsertFirstMessage = expectation(description: "Inserted first message")
        let message = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: message) {
            expectInsertFirstMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)

        let expectInsertSecondMessage = expectation(description: "Inserted second message")
        let message2 = MessagePayload(id: "id2", chatId: "chatId", senderId: "senderId",
                                      body: "body2", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: message2) {
            expectInsertSecondMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 2)
    }

    func testInsertedSameMessageTwiceDoesNotUpdateTableViewAgain() {

        let vc = chatViewController!
        let tableView = vc.tableView!

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)

        let messageManager = CoreDataMessageManager(persistentContainer: persistentContainer)

        let expectInsertFirstMessage = expectation(description: "Inserted first message")
        let message = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: message) {
            expectInsertFirstMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)

        let expectInsertSecondMessage = expectation(description: "Inserted second message")
        messageManager.insertOrUpdateMessage(message: message) {
            expectInsertSecondMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)
    }

    func testInsertSameMessageWithUpdatedBodyUpdatesCellLabelToNewBody() {

        let vc = chatViewController!
        let tableView = vc.tableView!

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)

        let messageManager = CoreDataMessageManager(persistentContainer: persistentContainer)

        let expectInsertFirstMessage = expectation(description: "Inserted first message")
        let message = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: message) {
            expectInsertFirstMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.textLabel?.text, "body")

        let expectInsertSecondMessage = expectation(description: "Inserted second message")
        let messageUpdated = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "body2", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: messageUpdated) {
            expectInsertSecondMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)

        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        let updatedCell = tableView.cellForRow(at: indexPath)
        XCTAssertEqual(updatedCell?.textLabel?.text, "body2")
    }

    func testDeleteMessageDeletesCell() {

        let vc = chatViewController!
        let tableView = vc.tableView!

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)

        let messageManager = CoreDataMessageManager(persistentContainer: persistentContainer)

        let expectInsertMessage = expectation(description: "Inserted message")
        let messageIdentity = MessageIdentity(id: "id", chatId: "chatId", senderId: "senderId")
        let message = MessagePayload(identity: messageIdentity, body: "body", timestamp: NSDate())
        messageManager.insertOrUpdateMessage(message: message) {
            expectInsertMessage.fulfill()
        }

        waitForExpectations(timeout: 1.0, handler: nil)

        DispatchQueue.main.async {
            XCTAssertEqual(tableView.numberOfSections, 1)
            XCTAssertEqual(tableView.numberOfRows(inSection: 0), 1)

            let expectDeleteMessage = self.expectation(description: "Deleted message")
            messageManager.deleteMessage(identity: messageIdentity) {
                expectDeleteMessage.fulfill()
            }

            self.waitForExpectations(timeout: 1.0, handler: nil)

            DispatchQueue.main.async {
                XCTAssertEqual(tableView.numberOfSections, 1)
                XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
            }
        }
    }

    func testUpdateMessageTimestampMovesMessageInTableview() {

        let firstMessageTime = NSDate()
        let secondMessageTime = firstMessageTime.addingTimeInterval(3.0)
        let thirdMessageTime = firstMessageTime.addingTimeInterval(6.0)
        let secondMessageTimeRevised = firstMessageTime.addingTimeInterval(9.0)

        let vc = chatViewController!
        let tableView = vc.tableView!

        XCTAssertEqual(tableView.numberOfSections, 1)
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)

        let messageManager = CoreDataMessageManager(persistentContainer: persistentContainer)

        let g = DispatchGroup()

        g.enter()
        let expectInsertFirstMessage = expectation(description: "Inserted first message")
        let message = MessagePayload(id: "id", chatId: "chatId", senderId: "senderId", body: "first", timestamp: firstMessageTime)
        messageManager.insertOrUpdateMessage(message: message) {
            expectInsertFirstMessage.fulfill()
            g.leave()
        }

        g.wait()

        g.enter()
        let expectInsertSecondMessage = expectation(description: "Inserted second message")
        let message2 = MessagePayload(id: "id2", chatId: "chatId", senderId: "senderId", body: "second", timestamp: secondMessageTime)
        messageManager.insertOrUpdateMessage(message: message2) {
            expectInsertSecondMessage.fulfill()
            g.leave()
        }

        g.wait()

        g.enter()
        let expectInsertThirdMessage = expectation(description: "Inserted third message")
        let message3 = MessagePayload(id: "id3", chatId: "chatId", senderId: "senderId", body: "third", timestamp: thirdMessageTime)
        messageManager.insertOrUpdateMessage(message: message3) {
            expectInsertThirdMessage.fulfill()
            g.leave()
        }

        g.wait()

        waitForExpectations(timeout: 1.0, handler: nil)

        DispatchQueue.main.async {
            XCTAssertEqual(tableView.numberOfSections, 1)
            XCTAssertEqual(tableView.numberOfRows(inSection: 0), 3)

            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
            XCTAssertNotNil(cell)
            XCTAssertEqual(cell?.textLabel?.text, "third")

            let expectUpdateSecondMessageTimestamp = self.expectation(description: "Update second message timestamp")
            let messageUpdated = MessagePayload(id: "id2", chatId: "chatId", senderId: "senderId", body: "second", timestamp: secondMessageTimeRevised)
            messageManager.insertOrUpdateMessage(message: messageUpdated) {
                expectUpdateSecondMessageTimestamp.fulfill()
            }

            self.waitForExpectations(timeout: 1.0, handler: nil)

            DispatchQueue.main.async {
                XCTAssertEqual(tableView.numberOfSections, 1)
                XCTAssertEqual(tableView.numberOfRows(inSection: 0), 3)

                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                let updatedCell = tableView.cellForRow(at: indexPath)
                XCTAssertEqual(updatedCell?.textLabel?.text, "second")
            }
        }
    }
}

// MARK: -

fileprivate struct MockChatService: ChatServiceProtocol {

    let chatId: String
    let senderId: String

    func sendMessage(body: String) {

    }
}
