//
//  BookFormat+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension BookFormat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookFormat> {
        return NSFetchRequest<BookFormat>(entityName: "BookFormat")
    }

    @NSManaged public var filePath: String?
    @NSManaged public var isDigital: Bool
    @NSManaged public var name: String?
    @NSManaged public var purchaseLink: String?
    @NSManaged public var book: Book?

}

extension BookFormat : Identifiable {

}
