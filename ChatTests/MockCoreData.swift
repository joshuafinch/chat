//
//  MockCoreData.swift
//  Chat
//
//  Created by Joshua Finch on 12/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData

@testable import Chat

class MockCoreData: CoreDataProtocol {

    var persistentContainer: NSPersistentContainer?

    func add(persistentContainerChangeDelegate: PersistentContainerChangeDelegate) {

    }

    func remove(persistentContainerChangeDelegate: PersistentContainerChangeDelegate) {

    }

    var onSaveViewContextCalled: (() -> Void)? = nil

    func saveViewContext() {
        onSaveViewContextCalled?()
    }
}
