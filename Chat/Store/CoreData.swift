//
//  CoreData.swift
//  Chat
//
//  Created by Joshua Finch on 04/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

protocol PersistentContainerChangeDelegate: class {

    func persistentContainerChanged(persistentContainer: NSPersistentContainer?)
}

protocol CoreDataProtocol {

    var persistentContainer: NSPersistentContainer? { get }
    
    func add(persistentContainerChangeDelegate: PersistentContainerChangeDelegate)
    func remove(persistentContainerChangeDelegate: PersistentContainerChangeDelegate)

    func saveViewContext()
}

class CoreData: CoreDataProtocol {
    
    enum StoreType {
        case InMemory
        case SQLite
    }
    
    typealias LoadedPersistentStoresHandler = (_ success: Bool) -> ()
    
    private(set) var persistentContainer: NSPersistentContainer? {
        didSet {
            weakDelegates.allObjects.forEach { (object) in
                if let delegate = object as? PersistentContainerChangeDelegate {
                    delegate.persistentContainerChanged(persistentContainer: persistentContainer)
                }
            }
        }
    }
    private let loadPersistentStoresCompletionHandler: LoadedPersistentStoresHandler
    
    private let name: String

    private var weakDelegates = NSHashTable<AnyObject>.weakObjects()
    
    // MARK: -
    
    init(name: String, storeType: StoreType, description: NSPersistentStoreDescription? = nil,
         loadPersistentStoresCompletionHandler: @escaping LoadedPersistentStoresHandler) {
        
        self.name = name
        self.loadPersistentStoresCompletionHandler = loadPersistentStoresCompletionHandler
        
        var d: NSPersistentStoreDescription? = description
        
        if d == nil {
            
            let description = NSPersistentStoreDescription()
            description.configuration = "Default"
            description.shouldAddStoreAsynchronously = true
            description.isReadOnly = false
            description.shouldInferMappingModelAutomatically = true
            description.shouldMigrateStoreAutomatically = true
            
            switch storeType {
            case .InMemory:
                description.type = NSInMemoryStoreType
                
            case .SQLite:
                
                let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let url = storeDirectory.appendingPathComponent("Chat.sqlite")
                
                description.type = NSSQLiteStoreType
                description.url = url
            }
            
            d = description
        }
        
        loadPersistentContainer(persistentStoreDescriptions: [d!])
    }
    
    func saveViewContext() {

        guard let persistentContainer = persistentContainer else {
            return
        }

        persistentContainer.viewContext.perform {
            do {
                try persistentContainer.viewContext.save()
            } catch let error {
                print("Error saving view context: \(error)")
            }
        }
    }

    // MARK: - Delegates

    func add(persistentContainerChangeDelegate: PersistentContainerChangeDelegate) {
        weakDelegates.add(persistentContainerChangeDelegate)
    }

    func remove(persistentContainerChangeDelegate: PersistentContainerChangeDelegate) {
        weakDelegates.remove(persistentContainerChangeDelegate)
    }

    // MARK: - Private
    
    private func loadPersistentContainer(persistentStoreDescriptions: [NSPersistentStoreDescription]) {
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
                self?.persistentContainer = nil
                print("Load persistent stores error: \(error), \(error.userInfo)")
                self?.loadPersistentStoresCompletionHandler(false)
            } else {
                container.viewContext.automaticallyMergesChangesFromParent = true
                self?.persistentContainer = container
                self?.loadPersistentStoresCompletionHandler(true)
            }
        })
        return
    }
}
