//
//  Location+CoreDataProperties.swift
//  GeoCrimes
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func locationFetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var id: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var crime: NSSet?
    @NSManaged public var street: Street?

}

// MARK: Generated accessors for crime
extension Location {

    @objc(addCrimeObject:)
    @NSManaged public func addToCrime(_ value: Crime)

    @objc(removeCrimeObject:)
    @NSManaged public func removeFromCrime(_ value: Crime)

    @objc(addCrime:)
    @NSManaged public func addToCrime(_ values: NSSet)

    @objc(removeCrime:)
    @NSManaged public func removeFromCrime(_ values: NSSet)

}
