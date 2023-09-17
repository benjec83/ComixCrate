//
//  Characters+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Characters {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Characters> {
        return NSFetchRequest<Characters>(entityName: "Characters")
    }

    @NSManaged public var name: String?
    @NSManaged public var books: NSSet?
    @NSManaged public var publisher: Publisher?

}

// MARK: Generated accessors for books
extension Characters {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: Book)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: Book)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}

extension Characters : Identifiable {

}
