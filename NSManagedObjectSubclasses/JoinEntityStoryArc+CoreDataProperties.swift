//
//  JoinEntityStoryArc+CoreDataProperties.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/17/23.
//
//

import Foundation
import CoreData


extension JoinEntityStoryArc {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JoinEntityStoryArc> {
        return NSFetchRequest<JoinEntityStoryArc>(entityName: "JoinEntityStoryArc")
    }

    @NSManaged public var storyArcPart: Int16
    @NSManaged public var book: Book?
    @NSManaged public var storyArc: StoryArc?

}

extension JoinEntityStoryArc : Identifiable {

}
