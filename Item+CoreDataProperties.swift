//
//  Item+CoreDataProperties.swift
//  GoldenGaiApp
//
//  Created by Shuhei Kinugasa on 2025/11/08.
//
//

public import Foundation
public import CoreData


public typealias ItemCoreDataPropertiesSet = NSSet

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date?

}

extension Item : Identifiable {

}
