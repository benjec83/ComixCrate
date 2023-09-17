//
//  JoinEntityCreator+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension JoinEntityCreator {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JoinEntityCreator> {
        return NSFetchRequest<JoinEntityCreator>(entityName: "JoinEntityCreator")
    }

    @NSManaged public var book: Book?
    @NSManaged public var creator: Creator?
    @NSManaged public var creatorRole: CreatorRole?

}

extension JoinEntityCreator : Identifiable {

}
