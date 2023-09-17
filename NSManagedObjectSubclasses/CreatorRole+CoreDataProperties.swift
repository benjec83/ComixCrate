//
//  CreatorRole+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension CreatorRole {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CreatorRole> {
        return NSFetchRequest<CreatorRole>(entityName: "CreatorRole")
    }

    @NSManaged public var name: String?
    @NSManaged public var creatorJoins: NSSet?

}

// MARK: Generated accessors for creatorJoins
extension CreatorRole {

    @objc(addCreatorJoinsObject:)
    @NSManaged public func addToCreatorJoins(_ value: JoinEntityCreator)

    @objc(removeCreatorJoinsObject:)
    @NSManaged public func removeFromCreatorJoins(_ value: JoinEntityCreator)

    @objc(addCreatorJoins:)
    @NSManaged public func addToCreatorJoins(_ values: NSSet)

    @objc(removeCreatorJoins:)
    @NSManaged public func removeFromCreatorJoins(_ values: NSSet)

}

extension CreatorRole : Identifiable {

}
