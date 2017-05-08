//
//  CoreData.swift
//  Chat
//
//  Created by Joshua Finch on 04/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    
    enum StoreType {
        case InMemory
        case SQLite
    }
    
    typealias LoadedPersistentStoresHandler = (_ success: Bool) -> ()
    
    private(set) var persistentContainer: NSPersistentContainer?
    private let loadPersistentStoresCompletionHandler: LoadedPersistentStoresHandler
    
    private let name: String
    
    // MARK: -
    
    init(name: String, storeType: StoreType, description: NSPersistentStoreDescription? = nil,
         loadPersistentStoresCompletionHandler: @escaping LoadedPersistentStoresHandler) {
        
        self.name = name
        self.loadPersistentStoresCompletionHandler = loadPersistentStoresCompletionHandler
        
        var d: NSPersistentStoreDescription? = description
        
        if d == nil {
            let description = NSPersistentStoreDescription()
            description.configuration = "Default"
            
            switch storeType {
            case .InMemory:
                description.type = NSInMemoryStoreType
            case .SQLite:
                description.type = NSSQLiteStoreType
            }
            d = description
        }
        
        self.persistentContainer = persistentContainer(persistentStoreDescriptions: [d!])
    }
    
    deinit {
        
    }
    
    // MARK: - Private
    
    private func persistentContainer(persistentStoreDescriptions: [NSPersistentStoreDescription]) -> NSPersistentContainer {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: name)
        container.persistentStoreDescriptions = persistentStoreDescriptions
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                self?.loadPersistentStoresCompletionHandler(false)
                print("Load persistent stores error: \(error), \(error.userInfo)")
            } else {
                self?.loadPersistentStoresCompletionHandler(true)
            }
        })
        return container
    }
}
