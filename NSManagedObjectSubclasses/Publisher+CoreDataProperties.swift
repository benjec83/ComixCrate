//
//  Publisher+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Publisher {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Publisher> {
        return NSFetchRequest<Publisher>(entityName: "Publisher")
    }

    @NSManaged public var name: String?
    @NSManaged public var publisherDescription: String?
    @NSManaged public var book: NSSet?
    @NSManaged public var charcters: NSSet?
    @NSManaged public var era: NSSet?
    @NSManaged public var location: NSSet?
    @NSManaged public var series: BookSeries?

}

// MARK: Generated accessors for book
extension Publisher {

    @objc(addBookObject:)
    @NSManaged public func addToBook(_ value: Book)

    @objc(removeBookObject:)
    @NSManaged public func removeFromBook(_ value: Book)

    @objc(addBook:)
    @NSManaged public func addToBook(_ values: NSSet)

    @objc(removeBook:)
    @NSManaged public func removeFromBook(_ values: NSSet)

}

// MARK: Generated accessors for charcters
extension Publisher {

    @objc(addCharctersObject:)
    @NSManaged public func addToCharcters(_ value: Characters)

    @objc(removeCharctersObject:)
    @NSManaged public func removeFromCharcters(_ value: Characters)

    @objc(addCharcters:)
    @NSManaged public func addToCharcters(_ values: NSSet)

    @objc(removeCharcters:)
    @NSManaged public func removeFromCharcters(_ values: NSSet)

}

// MARK: Generated accessors for era
extension Publisher {

    @objc(addEraObject:)
    @NSManaged public func addToEra(_ value: Era)

    @objc(removeEraObject:)
    @NSManaged public func removeFromEra(_ value: Era)

    @objc(addEra:)
    @NSManaged public func addToEra(_ values: NSSet)

    @objc(removeEra:)
    @NSManaged public func removeFromEra(_ values: NSSet)

}

// MARK: Generated accessors for location
extension Publisher {

    @objc(addLocationObject:)
    @NSManaged public func addToLocation(_ value: BookLocations)

    @objc(removeLocationObject:)
    @NSManaged public func removeFromLocation(_ value: BookLocations)

    @objc(addLocation:)
    @NSManaged public func addToLocation(_ values: NSSet)

    @objc(removeLocation:)
    @NSManaged public func removeFromLocation(_ values: NSSet)

}

extension Publisher : Identifiable {

}
