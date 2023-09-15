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

enum EntityType: String {
    case bookStoryArc = "BookStoryArcs"
    case bookEvents = "BookEvents"
    case creator = "Creators"
    
    var displayName: String {
        switch self {
        case .bookStoryArc: return "BookStoryArcs"
        case .bookEvents: return "BookEvents"
        case .creator: return "Creators"
        }
    }
    
    var iconName: String {
        switch self {
        case .bookStoryArc: return "sparkles.rectangle.stack.fill"
        case .bookEvents: return "theatermasks.fill"
        case .creator: return "paintpalette.fill"
        }
    }
    
    var attribute: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .bookStoryArc:
            return (field1: ("storyArc", "Story Arc"), field2: ("storyArcPart", "Story Arc Part"))
        case .creator:
            return (field1: ("creatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvents:
            return (field1: ("event", "Event Name"), field2: ("eventPart", "Part"))
        }
    }
    
    var attributes: (field1: (attributes: String, displayName: String), field2: (attributes: String, displayName: String)) {
        switch self {
        case .bookStoryArc:
            return (field1: ("name", "Story Arc"), field2: ("storyArcPart", "Story Arc Part"))
        case .creator:
            return (field1: ("creatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvents:
            return (field1: ("name", "Event Name"), field2: ("eventPart", "Part"))
        }
    }
    
    
    
    var headerText: String {
        switch self {
        case .bookStoryArc: return "Add an existing Story Arc"
        case .creator: return "Add an existing Creator Role"
        case .bookEvents: return "Add an existing Event"
        }
    }
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        switch self {
        case .bookStoryArc: return StoryArc.fetchRequest()
        case .bookEvents: return Event.fetchRequest()
        case .creator: return Creator.fetchRequest() // Assuming you have a Creator entity
        }
    }
    
    var fieldTypes: (FieldType, FieldType) {
        switch self {
        case .bookStoryArc:
            return (.string, .int16)
        case .creator:
            return (.string, .string)
        case .bookEvents:
            return (.string, .int16)
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
    
    func bindings(from viewModel: SelectedBookViewModel) -> (Binding<String>, Binding<String>) {
        switch self {
        case .bookStoryArc:
            return (
                Binding(
                    get: { viewModel.editedStoryArcName },
                    set: { viewModel.editedStoryArcName = $0 }
                ),
                Binding(
                    get: { viewModel.editedStoryArcPart },
                    set: { viewModel.editedStoryArcPart = $0 }
                )
            )
        case .bookEvents:
            return (
                Binding(
                    get: { viewModel.editedEventName },
                    set: { viewModel.editedEventName = $0 }
                ),
                Binding(
                    get: { viewModel.editedEventPart },
                    set: { viewModel.editedEventPart = $0 }
                )
            )
        case .creator:
            return (
                Binding(
                    get: { viewModel.editedCreatorName },
                    set: { viewModel.editedCreatorName = $0 }
                ),
                Binding(
                    get: { viewModel.editedCreatorRole },
                    set: { viewModel.editedCreatorRole = $0 }
                )
            )
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

enum FieldType {
    case string
    case int16
}

enum ComicFileHandlerError: Error {
    case invalidFileExtension
    case unzipFailed
    case invalidComicInfo
    case fileNotFound
    case invalidFile
    case missingComicInfo
}

enum ImageError: Error {
    case failedToLoadImage(String)
    case failedToResizeImage
    case failedToCacheImage
    case failedToRetrieveFromCache(String)
    
    var localizedDescription: String {
        switch self {
        case .failedToLoadImage(let path):
            return "Failed to load image from path: \(path)"
        case .failedToResizeImage:
            return "Failed to resize image."
        case .failedToCacheImage:
            return "Failed to cache image."
        case .failedToRetrieveFromCache(let key):
            return "Failed to retrieve image from cache with key: \(key)"
        }
    }
}

//enum EntityDetails {
//    case storyArc(Binding<String>, Binding<String>, FieldType, FieldType)
//    case bookEvents(Binding<String>, Binding<String>, FieldType, FieldType)
//    case creator(Binding<String>, Binding<String>, FieldType, FieldType)
//    
//    var rawValue: String {
//        switch self {
//        case .storyArc:
//            return "BookStoryArcs"
//        case .bookEvents:
//            return "BookEvents"
//        case .creator:
//            return "Creators"
//        }
//    }
//    
//    func iconName() -> String {
//        switch self {
//        case .storyArc:
//            return "sparkles.rectangle.stack.fill"
//        case .bookEvents:
//            return "theatermasks.fill"
//        case .creator:
//            return "paintpalette.fill"
//        }
//    }
//    
//    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
//        switch self {
//        case .storyArc:
//            return (field1: ("name", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
//        case .creator:
//            return (field1: ("creatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
//        case .bookEvents:
//            return (field1: ("name", "Event Name"), field2: ("eventPart", "Part"))
//        }
//    }
//    
//    var headerText: String {
//        switch self {
//        case .storyArc:
//            return "Add an existing Story Arc"
//        case .creator:
//            return "Add an existing Creator Role"
//        case .bookEvents:
//            return "Add an existing Event"
//        }
//    }
//    
//    var bindings: (Binding<String>, Binding<String>) {
//        switch self {
//        case .storyArc(let binding1, let binding2, _, _),
//                .creator(let binding1, let binding2, _, _),
//                .bookEvents(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        }
//    }
//    
//    var fieldTypes: (FieldType, FieldType) {
//        switch self {
//        case .storyArc(_, _, let type1, let type2),
//                .creator(_, _, let type1, let type2),
//                .bookEvents(_, _, let type1, let type2):
//            return (type1, type2)
//        }
//    }
//    
//    var keyboardTypeForField2: UIKeyboardType {
//        switch fieldTypes.1 {
//        case .string:
//            return .default
//        case .int16:
//            return .numberPad
//        }
//    }
//}
//// MARK: - ChipType Enum
//enum ChipType: String {
//    case bookStoryArc = "BookStoryArcs"
//    case bookEvents = "BookEvents"
//    case creator = "Creators"
//    // Add other types as needed
//
//    func iconName() -> String {
//        switch self {
//        case .bookStoryArc:
//            return "sparkles.rectangle.stack.fill"
//        case .bookEvents:
//            return "theatermasks.fill"
//        case .creator:
//            return "paintpalette.fill"
//        }
//    }
//    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
//        switch self {
//        case .bookStoryArc:
//            return StoryArc.fetchRequest()
//        case .bookEvents:
//            return Event.fetchRequest()
//        case .creator:
//            // Assuming you have a Creator entity
//            return Creator.fetchRequest()
//        }
//    }
//    var correspondingTextFieldEntity: TextFieldEntities {
//        switch self {
//        case .bookStoryArc:
//            return .bookStoryArcs(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
//        case .bookEvents:
//            return .bookEvents(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
//        case .creator:
//            return .bookCreatorRole(Binding.constant(""), Binding.constant(""), .string, .string) // Provide default bindings and field types
//        }
//    }
//}
//
//extension ChipType {
//    init?(entity: String) {
//        switch entity {
//        case "BookStoryArcs":
//            self = .bookStoryArc
//        case "BookEvents":
//            self = .bookEvents
//        case "Creators":
//            self = .creator
//        default:
//            return nil
//        }
//    }
//}

//enum TextFieldEntities {
//    case bookStoryArcs(Binding<String>, Binding<String>, FieldType, FieldType)
//    case bookCreatorRole(Binding<String>, Binding<String>, FieldType, FieldType)
//    case bookEvents(Binding<String>, Binding<String>, FieldType, FieldType)
//    
//    
//    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
//        switch self {
//        case .bookStoryArcs:
//            return (field1: ("name", "Story Arc"), field2: ("storyArcPart", "Story Arc Part"))
//        case .bookCreatorRole:
//            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
//        case .bookEvents:
//            return (field1: ("name", "Event Name"), field2: ("eventPart", "Part"))
//        }
//    }
//    
//    var editAttributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
//        switch self {
//        case .bookStoryArcs:
//            return (field1: ("$editedStoryArcName", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
//        case .bookCreatorRole:
//            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
//        case .bookEvents:
//            return (field1: ("$editedEventName", "Event Name"), field2: ("eventPart", "Part"))
//        }
//    }
//    
//    var headerText: String {
//        switch self {
//        case .bookStoryArcs:
//            return "Add an existing Story Arc"
//        case .bookCreatorRole:
//            return "Add an existing Creator Role"
//        case .bookEvents:
//            return "Add an existing Event"
//        }
//    }
//    
//    var bindings: (Binding<String>, Binding<String>) {
//        switch self {
//        case .bookStoryArcs(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        case .bookCreatorRole(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        case .bookEvents(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        }
//    }
//    
//    var fieldTypes: (FieldType, FieldType) {
//        switch self {
//        case .bookStoryArcs(_, _, let type1, let type2):
//            return (type1, type2)
//        case .bookCreatorRole(_, _, let type1, let type2):
//            return (type1, type2)
//        case .bookEvents(_, _, let type1, let type2):
//            return (type1, type2)
//        }
//    }
//    var keyboardTypeForField2: UIKeyboardType {
//        switch fieldTypes.1 {
//        case .string:
//            return .default
//        case .int16:
//            return .numberPad
//        }
//    }
//    var chipType: ChipType {
//        switch self {
//        case .bookStoryArcs:
//            return .bookStoryArc
//        case .bookCreatorRole:
//            return .creator
//        case .bookEvents:
//            return .bookEvents
//        }
//    }
//}


