//
//  AppDelegate.swift
//  Chat
//
//  Created by Joshua Finch on 04/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import UIKit
import CoreData

class AppDelegate: UIResponder, UIApplicationDelegate {

    struct State {
        let coreData: CoreDataProtocol
        let coreDataMessageManager: CoreDataMessageManaging
        let messageImporter: MessageImporting

        func buildChat(chatId: String) -> ChatViewController {
            let chatService = ChatService(chatId: chatId, senderId: "senderId", messageImporter: messageImporter)

            let chatViewController = ChatViewController()
            chatViewController.state = ChatViewController.State(chatService: chatService,
                                                                persistentContainer: coreData.persistentContainer)
            coreData.add(persistentContainerChangeDelegate: chatViewController)

            return chatViewController
        }
    }

    var window: UIWindow?

    var state: State?
    
    // MARK: - Application Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupWindow()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        state?.coreData.saveViewContext()
    }

    // MARK: - Private

    private func setupState() {

        guard state == nil else {
            // State is already setup
            return
        }

        if state == nil {

            let coreData = createCoreData()

            let coreDataMessageManager = CoreDataMessageManager(persistentContainer: coreData.persistentContainer)
            coreData.add(persistentContainerChangeDelegate: coreDataMessageManager)

            let messageImporter = MessageImporter(label: "message.importer", coreDataMessageManager: coreDataMessageManager)

            state = State(coreData: coreData, 
                          coreDataMessageManager: coreDataMessageManager, 
                          messageImporter: messageImporter)
        }
    }

    private func createCoreData() -> CoreDataProtocol {
        let coreData = CoreData(name: "Model", storeType: .SQLite, loadPersistentStoresCompletionHandler: { (success) in
            if !success {
                // TODO: Could not load core data persistent stores, unsafe to do other core data operations
                // This indicates a significant error we may want to make the user aware of.
            }
        })

        return coreData
    }

    private func setupWindow() {

        setupState()

        guard let state = state else {
            return
        }

        let chatViewController = state.buildChat(chatId: "chatId")
        let navigationController = UINavigationController(rootViewController: chatViewController)

        window = UIWindow()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

