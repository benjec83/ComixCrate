//
//  Event+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var eventDescription: String?
    @NSManaged public var name: String?
    @NSManaged public var book: NSSet?
    @NSManaged public var booksInEvent: NSSet?

}

// MARK: Generated accessors for book
extension Event {

    @objc(addBookObject:)
    @NSManaged public func addToBook(_ value: Book)

    @objc(removeBookObject:)
    @NSManaged public func removeFromBook(_ value: Book)

    @objc(addBook:)
    @NSManaged public func addToBook(_ values: NSSet)

    @objc(removeBook:)
    @NSManaged public func removeFromBook(_ values: NSSet)

}

// MARK: Generated accessors for booksInEvent
extension Event {

    @objc(addBooksInEventObject:)
    @NSManaged public func addToBooksInEvent(_ value: JoinEntityEvent)

    @objc(removeBooksInEventObject:)
    @NSManaged public func removeFromBooksInEvent(_ value: JoinEntityEvent)

    @objc(addBooksInEvent:)
    @NSManaged public func addToBooksInEvent(_ values: NSSet)

    @objc(removeBooksInEvent:)
    @NSManaged public func removeFromBooksInEvent(_ values: NSSet)

}

extension Event : Identifiable {

}
