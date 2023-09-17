//
//  BookSeries+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension BookSeries {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookSeries> {
        return NSFetchRequest<BookSeries>(entityName: "BookSeries")
    }

    @NSManaged public var dateFinished: Date?
    @NSManaged public var dateStart: Date?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var seriesDescription: String?
    @NSManaged public var book: NSSet?
    @NSManaged public var publisher: Publisher?

}

// MARK: Generated accessors for book
extension BookSeries {

    @objc(addBookObject:)
    @NSManaged public func addToBook(_ value: Book)

    @objc(removeBookObject:)
    @NSManaged public func removeFromBook(_ value: Book)

    @objc(addBook:)
    @NSManaged public func addToBook(_ values: NSSet)

    @objc(removeBook:)
    @NSManaged public func removeFromBook(_ values: NSSet)

}

extension BookSeries : Identifiable {

}
