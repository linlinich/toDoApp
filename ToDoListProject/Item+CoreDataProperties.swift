//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Ангелина Решетникова on 15.07.2023.
//
//

import Foundation
import CoreData


extension Item {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var dateOfChange: Date
    @NSManaged public var dateOfCreation: Date
    @NSManaged public var deadline: Date?
    @NSManaged public var didDone: Bool
    @NSManaged public var id: String
    @NSManaged public var importance: String
    @NSManaged public var lastUpdated: String
    @NSManaged public var text: String

}
