//
//  StoryArc+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension StoryArc {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryArc> {
        return NSFetchRequest<StoryArc>(entityName: "StoryArc")
    }

    @NSManaged public var name: String?
    @NSManaged public var storyArcDescription: String?
    @NSManaged public var storyArcPart: Int16
    @NSManaged public var book: NSSet?
    @NSManaged public var booksInArc: NSSet?

}

// MARK: Generated accessors for book
extension StoryArc {

    @objc(addBookObject:)
    @NSManaged public func addToBook(_ value: Book)

    @objc(removeBookObject:)
    @NSManaged public func removeFromBook(_ value: Book)

    @objc(addBook:)
    @NSManaged public func addToBook(_ values: NSSet)

    @objc(removeBook:)
    @NSManaged public func removeFromBook(_ values: NSSet)

}

// MARK: Generated accessors for booksInArc
extension StoryArc {

    @objc(addBooksInArcObject:)
    @NSManaged public func addToBooksInArc(_ value: JoinEntityStoryArc)

    @objc(removeBooksInArcObject:)
    @NSManaged public func removeFromBooksInArc(_ value: JoinEntityStoryArc)

    @objc(addBooksInArc:)
    @NSManaged public func addToBooksInArc(_ values: NSSet)

    @objc(removeBooksInArc:)
    @NSManaged public func removeFromBooksInArc(_ values: NSSet)

}

extension StoryArc : Identifiable {

}
