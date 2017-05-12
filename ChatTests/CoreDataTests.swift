//
//  CoreDataTests.swift
//  Chat
//
//  Created by Joshua Finch on 06/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable import Chat

class CoreDataTests: XCTestCase {
 
    private var coreData: CoreData?
    
    func testCreateCoreDataInMemoryStoreLoadsPersistentStores() {
        
        let expect = expectation(description: "Loads in memory persistent stores successfully")
        
        coreData = CoreData(name: "Model", storeType: .InMemory, loadPersistentStoresCompletionHandler: { success in
            if success {
                expect.fulfill()
            } else {
                XCTFail("Could not load persistent stores successfully")
            }
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCreateCoreDataSQLiteStoreLoadsPersistentStores() {
        
        let expect = expectation(description: "Loads SQLite persistent stores successfully")
        
        coreData = CoreData(name: "Model", storeType: .SQLite, loadPersistentStoresCompletionHandler: { success in
            if success {
                expect.fulfill()
            } else {
                XCTFail("Could not load persistent stores successfully")
            }
        })
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCreateCoreDataStoreLoadPersistentStoresCallbackFailureScenario() {
     
        let expect = expectation(description: "Fails to load persistent store without correct model name")
        
        let description = NSPersistentStoreDescription()
        description.configuration = "Default"
        description.type = NSSQLiteStoreType
        description.url = URL(fileURLWithPath: "")
        
        coreData = CoreData(name: "Model", storeType: .SQLite, description: description,
                            loadPersistentStoresCompletionHandler: { success in
            if success {
                XCTFail("Loaded persistent stores despite error")
            } else {
                expect.fulfill()
            }
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
