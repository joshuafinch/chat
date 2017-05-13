//
//  Message+CoreDataProperties.swift
//  Chat
//
//  Created by Joshua Finch on 06/05/2017.
//  Copyright © 2017 Joshua Finch. All rights reserved.
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var id: String?
    @NSManaged public var body: String?
    @NSManaged public var senderId: String?
    @NSManaged public var chatId: String?

    enum Constants: String {
        case sectionIdentifier = "sectionIdentifier"
        case timestamp = "timestamp"
    }

    var timestamp: NSDate? {
        get {
            self.willAccessValue(forKey: Constants.timestamp.rawValue)
            let timestamp = self.primitiveValue(forKey: Constants.timestamp.rawValue) as? NSDate
            self.didAccessValue(forKey: Constants.timestamp.rawValue)
            return timestamp
        }
        set {
            self.willChangeValue(forKey: Constants.timestamp.rawValue)
            self.setPrimitiveValue(newValue, forKey: Constants.timestamp.rawValue)
            self.didChangeValue(forKey: Constants.timestamp.rawValue)

            self.setPrimitiveValue(nil, forKey: Constants.sectionIdentifier.rawValue)
        }
    }

    var sectionIdentifier: String? {
        get {
            self.willAccessValue(forKey: Constants.sectionIdentifier.rawValue)
            var sectionIdentifier = self.primitiveValue(forKey: Constants.sectionIdentifier.rawValue) as? String
            self.didAccessValue(forKey: Constants.sectionIdentifier.rawValue)

            if sectionIdentifier == nil {
                let timestamp = primitiveValue(forKey: Constants.timestamp.rawValue) as? Date
                if let timestamp = timestamp {
                    sectionIdentifier = string(fromDate: timestamp)
                    setPrimitiveValue(sectionIdentifier, forKey: Constants.sectionIdentifier.rawValue)
                }
            }

            return sectionIdentifier
        }
        set {
            self.willChangeValue(forKey: Constants.sectionIdentifier.rawValue)
            self.setPrimitiveValue(newValue, forKey: Constants.sectionIdentifier.rawValue)
            self.didChangeValue(forKey: Constants.sectionIdentifier.rawValue)
        }
    }

    dynamic class func keyPathsForValuesAffectingSectionIdentifier() -> Set<String> {
        return [Constants.timestamp.rawValue]
    }

    private func string(fromDate date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d%02d%02d", components.year!, components.month!, components.day!)
    }
}
