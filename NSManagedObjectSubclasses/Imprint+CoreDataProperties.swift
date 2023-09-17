//
//  Imprint+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Imprint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Imprint> {
        return NSFetchRequest<Imprint>(entityName: "Imprint")
    }

    @NSManaged public var name: String?
    @NSManaged public var book: Book?
    @NSManaged public var publisher: Publisher?

}

extension Imprint : Identifiable {

}
