//
//  Book+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var cachedThumbnailData: Data?
    @NSManaged public var communityRating: Double
    @NSManaged public var condition: String?
    @NSManaged public var coverDate: Date?
    @NSManaged public var coverPrice: NSDecimalNumber?
    @NSManaged public var currentValue: NSDecimalNumber?
    @NSManaged public var dateAdded: Date?
    @NSManaged public var dateModified: Date?
    @NSManaged public var downloaded: Bool
    @NSManaged public var fileName: String?
    @NSManaged public var filePath: String?
    @NSManaged public var gradedBy: String?
    @NSManaged public var gradeValue: NSDecimalNumber?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var issueNumber: Int16
    @NSManaged public var language: String?
    @NSManaged public var notes: String?
    @NSManaged public var pageCount: Int16
    @NSManaged public var personalRating: Double
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchaseFrom: String?
    @NSManaged public var purchasePrice: NSDecimalNumber?
    @NSManaged public var read: NSDecimalNumber?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var summary: String?
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var title: String?
    @NSManaged public var volumeNumber: Int16
    @NSManaged public var volumeYear: Int16
    @NSManaged public var web: String?
    @NSManaged public var creatorJoins: NSSet?
    @NSManaged public var eventJoins: NSSet?
    @NSManaged public var bookSeries: BookSeries?
    @NSManaged public var arcJoins: NSSet?
    @NSManaged public var characters: NSSet?
    @NSManaged public var era: NSSet?
    @NSManaged public var formats: NSSet?
    @NSManaged public var imprint: Imprint?
    @NSManaged public var locations: NSSet?
    @NSManaged public var publisher: Publisher?
    @NSManaged public var teams: NSSet?

}

// MARK: Generated accessors for creatorJoins
extension Book {

    @objc(addCreatorJoinsObject:)
    @NSManaged public func addToCreatorJoins(_ value: JoinEntityCreator)

    @objc(removeCreatorJoinsObject:)
    @NSManaged public func removeFromCreatorJoins(_ value: JoinEntityCreator)

    @objc(addCreatorJoins:)
    @NSManaged public func addToCreatorJoins(_ values: NSSet)

    @objc(removeCreatorJoins:)
    @NSManaged public func removeFromCreatorJoins(_ values: NSSet)

}

// MARK: Generated accessors for eventJoins
extension Book {

    @objc(addEventJoinsObject:)
    @NSManaged public func addToEventJoins(_ value: JoinEntityEvent)

    @objc(removeEventJoinsObject:)
    @NSManaged public func removeFromEventJoins(_ value: JoinEntityEvent)

    @objc(addEventJoins:)
    @NSManaged public func addToEventJoins(_ values: NSSet)

    @objc(removeEventJoins:)
    @NSManaged public func removeFromEventJoins(_ values: NSSet)

}

// MARK: Generated accessors for arcJoins
extension Book {

    @objc(addArcJoinsObject:)
    @NSManaged public func addToArcJoins(_ value: JoinEntityStoryArc)

    @objc(removeArcJoinsObject:)
    @NSManaged public func removeFromArcJoins(_ value: JoinEntityStoryArc)

    @objc(addArcJoins:)
    @NSManaged public func addToArcJoins(_ values: NSSet)

    @objc(removeArcJoins:)
    @NSManaged public func removeFromArcJoins(_ values: NSSet)

}

// MARK: Generated accessors for characters
extension Book {

    @objc(addCharactersObject:)
    @NSManaged public func addToCharacters(_ value: Characters)

    @objc(removeCharactersObject:)
    @NSManaged public func removeFromCharacters(_ value: Characters)

    @objc(addCharacters:)
    @NSManaged public func addToCharacters(_ values: NSSet)

    @objc(removeCharacters:)
    @NSManaged public func removeFromCharacters(_ values: NSSet)

}

// MARK: Generated accessors for era
extension Book {

    @objc(addEraObject:)
    @NSManaged public func addToEra(_ value: Era)

    @objc(removeEraObject:)
    @NSManaged public func removeFromEra(_ value: Era)

    @objc(addEra:)
    @NSManaged public func addToEra(_ values: NSSet)

    @objc(removeEra:)
    @NSManaged public func removeFromEra(_ values: NSSet)

}

// MARK: Generated accessors for formats
extension Book {

    @objc(addFormatsObject:)
    @NSManaged public func addToFormats(_ value: BookFormat)

    @objc(removeFormatsObject:)
    @NSManaged public func removeFromFormats(_ value: BookFormat)

    @objc(addFormats:)
    @NSManaged public func addToFormats(_ values: NSSet)

    @objc(removeFormats:)
    @NSManaged public func removeFromFormats(_ values: NSSet)

}

// MARK: Generated accessors for locations
extension Book {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: BookLocations)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: BookLocations)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

// MARK: Generated accessors for teams
extension Book {

    @objc(addTeamsObject:)
    @NSManaged public func addToTeams(_ value: Teams)

    @objc(removeTeamsObject:)
    @NSManaged public func removeFromTeams(_ value: Teams)

    @objc(addTeams:)
    @NSManaged public func addToTeams(_ values: NSSet)

    @objc(removeTeams:)
    @NSManaged public func removeFromTeams(_ values: NSSet)

}

extension Book : Identifiable {

}
