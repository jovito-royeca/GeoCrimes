//
//  Crime+CoreDataProperties.swift
//  GeoCrimes
//
//  Created by Jovito Royeca on 28/06/2018.
//  Copyright © 2018 Jovito Royeca. All rights reserved.
//
//

import Foundation
import CoreData


extension Crime {

    @nonobjc public class func crimeFetchRequest() -> NSFetchRequest<Crime> {
        return NSFetchRequest<Crime>(entityName: "Crime")
    }

    @NSManaged public var category: String?
    @NSManaged public var context: String?
    @NSManaged public var id: String?
    @NSManaged public var locationSubtype: String?
    @NSManaged public var locationType: String?
    @NSManaged public var month: String?
    @NSManaged public var persistentId: String?
    @NSManaged public var location: Location?

}
