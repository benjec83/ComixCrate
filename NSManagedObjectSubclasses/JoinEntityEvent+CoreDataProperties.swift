//
//  JoinEntityEvent+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension JoinEntityEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JoinEntityEvent> {
        return NSFetchRequest<JoinEntityEvent>(entityName: "JoinEntityEvent")
    }

    @NSManaged public var eventPart: Int16
    @NSManaged public var books: Book?
    @NSManaged public var events: Event?

}

extension JoinEntityEvent : Identifiable {

}
