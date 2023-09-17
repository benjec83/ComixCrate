//
//  Creator+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension Creator {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Creator> {
        return NSFetchRequest<Creator>(entityName: "Creator")
    }

    @NSManaged public var creatorBio: String?
    @NSManaged public var creatorBirthday: Date?
    @NSManaged public var creatorDeathDate: Date?
    @NSManaged public var creatorProfilePic: Data?
    @NSManaged public var creatorSocial: String?
    @NSManaged public var creatorWebsite: String?
    @NSManaged public var name: String?
    @NSManaged public var creatorJoins: NSSet?

}

// MARK: Generated accessors for creatorJoins
extension Creator {

    @objc(addCreatorJoinsObject:)
    @NSManaged public func addToCreatorJoins(_ value: JoinEntityCreator)

    @objc(removeCreatorJoinsObject:)
    @NSManaged public func removeFromCreatorJoins(_ value: JoinEntityCreator)

    @objc(addCreatorJoins:)
    @NSManaged public func addToCreatorJoins(_ values: NSSet)

    @objc(removeCreatorJoins:)
    @NSManaged public func removeFromCreatorJoins(_ values: NSSet)

}

extension Creator : Identifiable {

}
