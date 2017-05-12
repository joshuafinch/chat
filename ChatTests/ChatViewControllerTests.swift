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
}

// MARK: -

fileprivate struct MockChatService: ChatServiceProtocol {

    let chatId: String
    let senderId: String

    func sendMessage(body: String) {

    }
}
