//
//  Street+CoreDataProperties.swift
//  GeoCrimes
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension Street {

    @nonobjc public class func streetFetchRequest() -> NSFetchRequest<Street> {
        return NSFetchRequest<Street>(entityName: "Street")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var location: NSSet?

}

// MARK: Generated accessors for location
extension Street {

    @objc(addLocationObject:)
    @NSManaged public func addToLocation(_ value: Location)

    @objc(removeLocationObject:)
    @NSManaged public func removeFromLocation(_ value: Location)

    @objc(addLocation:)
    @NSManaged public func addToLocation(_ values: NSSet)

    @objc(removeLocation:)
    @NSManaged public func removeFromLocation(_ values: NSSet)

}
