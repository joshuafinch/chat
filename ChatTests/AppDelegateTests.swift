//
//  AppDelegateTests.swift
//  Chat
//
//  Created by Joshua Finch on 11/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import XCTest

@testable import Chat

class AppDelegateTests: XCTestCase {

    private let application = UIApplication.shared
    private var appDelegate: AppDelegate!

    private var coreData: MockCoreData!
    private var coreDataMessageManager: MockCoreDataMessageManaging!
    private var messageImporter: MockMessageImporting!

    override func setUp() {
        super.setUp()

        coreData = MockCoreData()
        coreDataMessageManager = MockCoreDataMessageManaging()
        messageImporter = MockMessageImporting()

        appDelegate = AppDelegate()
        appDelegate?.state = AppDelegate.State(coreData: coreData,
                                               coreDataMessageManager: coreDataMessageManager,
                                               messageImporter: messageImporter)
    }

    func testAppDelegateSetupWindowWhenDidFinishLaunching() {
        let result = appDelegate.application(application, didFinishLaunchingWithOptions: nil)
        XCTAssert(result)
        XCTAssertNotNil(appDelegate.window)
        XCTAssert(appDelegate.window!.isKeyWindow)
        XCTAssert(!appDelegate.window!.isHidden)
        XCTAssertNotNil(appDelegate.window!.rootViewController)
    }

    func testAppDelegate_WillTerminate_SavesCoreDataViewContext() {

        let expect = expectation(description: "saveViewContext called")

        coreData.onSaveViewContextCalled = {
            expect.fulfill()
        }

        let application = UIApplication.shared
        appDelegate.applicationWillTerminate(application)

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
