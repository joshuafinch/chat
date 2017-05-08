//
//  main.swift
//  Chat
//
//  Created by Joshua Finch on 08/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import UIKit

private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

let unsafeArgv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))

UIApplicationMain(CommandLine.argc, unsafeArgv, nil, delegateClassName())
