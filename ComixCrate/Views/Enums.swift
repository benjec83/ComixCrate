//
//  Enums.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import Foundation
import SwiftUI
import CoreData

enum LibraryFilter: String {
    case allBooks = "All Books"
    case favorites = "Favorites"
    case recentlyAdded = "Recently Added"
    case currentlyReading = "Currently Reading"
    // ... any other filter states
}

// MARK: - ChipType Enum
enum ChipType: String {
    case bookStoryArc = "BookStoryArcs"
    case bookEvents = "BookEvents"
    case creator = "Creators"
    // Add other types as needed
    
    func iconName() -> String {
        switch self {
        case .bookStoryArc:
            return "sparkles.rectangle.stack.fill"
        case .bookEvents:
            return "theatermasks.fill"
        case .creator:
            return "paintpalette.fill"
        }
    }
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        switch self {
        case .bookStoryArc:
            return StoryArc.fetchRequest()
        case .bookEvents:
            return Event.fetchRequest()
        case .creator:
            // Assuming you have a Creator entity
            return Creator.fetchRequest()
        }
    }
    var correspondingTextFieldEntity: TextFieldEntities {
        switch self {
        case .bookStoryArc:
            return .bookStoryArcs(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
        case .bookEvents:
            return .bookEvents(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
        case .creator:
            return .bookCreatorRole(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
        }
    }
}

enum ValueData: Hashable {
    case string(String)
    case int16(Int16)
}

extension ValueData: Equatable {
    static func == (lhs: ValueData, rhs: ValueData) -> Bool {
        switch (lhs, rhs) {
        case (.string(let lhsString), .string(let rhsString)):
            return lhsString == rhsString
        case (.int16(let lhsInt), .int16(let rhsInt)):
            return lhsInt == rhsInt
        default:
            return false
        }
    }
}

enum TextFieldEntities {
    case bookStoryArcs(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookCreatorRole(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookEvents(Binding<String>, Binding<String>, FieldType, FieldType)
    
    
    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .bookStoryArcs:
            return (field1: ("storyArcName", "Story Arc"), field2: ("storyArcPart", "Story Arc Part"))
        case .bookCreatorRole:
            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvents:
            return (field1: ("eventName", "Event Name"), field2: ("eventPart", "Part"))
        }
    }
    
    var editAttributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .bookStoryArcs:
            return (field1: ("$editedStoryArcName", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
        case .bookCreatorRole:
            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvents:
            return (field1: ("eventName", "Event Name"), field2: ("eventPart", "Part"))
        }
    }
    
    var headerText: String {
        switch self {
        case .bookStoryArcs:
            return "Add an existing Story Arc"
        case .bookCreatorRole:
            return "Add an existing Creator Role"
        case .bookEvents:
            return "Add an existing Event"
        }
    }
    
    var bindings: (Binding<String>, Binding<String>) {
        switch self {
        case .bookStoryArcs(let binding1, let binding2, _, _):
            return (binding1, binding2)
        case .bookCreatorRole(let binding1, let binding2, _, _):
            return (binding1, binding2)
        case .bookEvents(let binding1, let binding2, _, _):
            return (binding1, binding2)
        }
    }
    
    var fieldTypes: (FieldType, FieldType) {
        switch self {
        case .bookStoryArcs(_, _, let type1, let type2):
            return (type1, type2)
        case .bookCreatorRole(_, _, let type1, let type2):
            return (type1, type2)
        case .bookEvents(_, _, let type1, let type2):
            return (type1, type2)
        }
    }
    var keyboardTypeForField2: UIKeyboardType {
        switch fieldTypes.1 {
        case .string:
            return .default
        case .int16:
            return .numberPad
        }
    }
    var chipType: ChipType {
        switch self {
        case .bookStoryArcs:
            return .bookStoryArc
        case .bookCreatorRole:
            return .creator
        case .bookEvents:
            return .bookEvents
        }
    }
}

enum FieldType {
    case string
    case int16
}


enum EntityDetails {
    case storyArc(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookEvents(Binding<String>, Binding<String>, FieldType, FieldType)
    case creator(Binding<String>, Binding<String>, FieldType, FieldType)
    
    var rawValue: String {
        switch self {
        case .storyArc:
            return "BookStoryArcs"
        case .bookEvents:
            return "BookEvents"
        case .creator:
            return "Creators"
        }
    }
    
    func iconName() -> String {
        switch self {
        case .storyArc:
            return "sparkles.rectangle.stack.fill"
        case .bookEvents:
            return "theatermasks.fill"
        case .creator:
            return "paintpalette.fill"
        }
    }
    
    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .storyArc:
            return (field1: ("storyArcName", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
        case .creator:
            return (field1: ("creatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvents:
            return (field1: ("eventName", "Event Name"), field2: ("eventPart", "Part"))
        }
    }
    
    var headerText: String {
        switch self {
        case .storyArc:
            return "Add an existing Story Arc"
        case .creator:
            return "Add an existing Creator Role"
        case .bookEvents:
            return "Add an existing Event"
        }
    }
    
    var bindings: (Binding<String>, Binding<String>) {
        switch self {
        case .storyArc(let binding1, let binding2, _, _),
                .creator(let binding1, let binding2, _, _),
                .bookEvents(let binding1, let binding2, _, _):
            return (binding1, binding2)
        }
    }
    
    var fieldTypes: (FieldType, FieldType) {
        switch self {
        case .storyArc(_, _, let type1, let type2),
                .creator(_, _, let type1, let type2),
                .bookEvents(_, _, let type1, let type2):
            return (type1, type2)
        }
    }
    
    var keyboardTypeForField2: UIKeyboardType {
        switch fieldTypes.1 {
        case .string:
            return .default
        case .int16:
            return .numberPad
        }
    }
}

//enum EntitySection {
//    case storyArc
//    case event
//    // Add other entities as needed
//
//    var headerText: String {
//        switch self {
//        case .storyArc: return "Story Arcs"
//        case .event: return "Events"
//        }
//    }
//
//    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
//        switch self {
//        case .storyArc: return StoryArc.fetchRequest()
//        case .event: return Event.fetchRequest()
//        }
//    }
//
//    var sortDescriptorKeyPath: AnyKeyPath {
//        switch self {
//        case .storyArc: return \StoryArc.storyArcName
//        case .event: return \Event.eventName
//        }
//    }
//
//    var chipType: ChipType {
//        switch self {
//        case .storyArc: return .storyArc
//        case .event: return .bookEvents
//        }
//    }
//
//    var editedAttribute1: Binding<String> {
//        switch self {
//        case .storyArc: return $editedStoryArcName
//        case .event: return $editedEventName
//        }
//    }
//
//    var editedAttribute2: Binding<String> {
//        switch self {
//        case .storyArc: return $editedStoryArcPart
//        case .event: return $editedEventPart
//        }
//    }
//
//    var entityType: EntityType {
//        switch self {
//        case .storyArc: return .bookStoryArc(editedAttribute1, editedAttribute2, .string, .int16)
//        case .event: return .bookEvents(editedAttribute1, editedAttribute2, .string, .int16)
//        }
//    }
//}
