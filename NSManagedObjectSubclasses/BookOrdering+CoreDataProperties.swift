//
//  BookOrdering+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension BookOrdering {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookOrdering> {
        return NSFetchRequest<BookOrdering>(entityName: "BookOrdering")
    }

    @NSManaged public var order: Int16
    @NSManaged public var book: Book?
    @NSManaged public var event: Event?
    @NSManaged public var readingList: ReadingList?
    @NSManaged public var storyArc: StoryArc?

}

extension BookOrdering : Identifiable {

}
