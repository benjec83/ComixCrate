//
//  Page+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Page {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged public var pageNumber: Int16
    @NSManaged public var pageType: String?
    @NSManaged public var book: Book?

}

extension Page : Identifiable {

}
