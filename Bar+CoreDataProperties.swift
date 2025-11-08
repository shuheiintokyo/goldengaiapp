//
//  Bar+CoreDataProperties.swift
//  GoldenGaiApp
//
//  Created by Shuhei Kinugasa on 2025/11/08.
//
//

public import Foundation
public import CoreData


public typealias BarCoreDataPropertiesSet = NSSet

extension Bar {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bar> {
        return NSFetchRequest<Bar>(entityName: "Bar")
    }

    @NSManaged public var uuid: String?
    @NSManaged public var name: String?
    @NSManaged public var nameJapanese: String?
    @NSManaged public var visited: Bool
    @NSManaged public var visitedDate: Date?
    @NSManaged public var photoURLs: Array?
    @NSManaged public var tags: Array?
    @NSManaged public var lastSyncedDate: Date?

}

extension Bar : Identifiable {

}
