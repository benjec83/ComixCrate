//
//  ReadingList+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension ReadingList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReadingList> {
        return NSFetchRequest<ReadingList>(entityName: "ReadingList")
    }

    @NSManaged public var listDescription: String?
    @NSManaged public var name: String?

}

extension ReadingList : Identifiable {

}
