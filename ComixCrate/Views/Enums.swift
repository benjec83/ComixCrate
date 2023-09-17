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
    case joinEntityStoryArc = "JoinEntityStoryArcs"
    case joinEntityEvent = "JoinEntityEvent"
    case creator = "Creators"
    
    var displayName: String {
        switch self {
        case .joinEntityStoryArc: return "JoinEntityStoryArcs"
        case .joinEntityEvent: return "JoinEntityEvent"
        case .creator: return "Creators"
        }
    }
    
    var iconName: String {
        switch self {
        case .joinEntityStoryArc: return "sparkles.rectangle.stack.fill"
        case .joinEntityEvent: return "theatermasks.fill"
        case .creator: return "paintpalette.fill"
        }
    }
    
    var attribute: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .joinEntityStoryArc:
            return (field1: ("storyArc", "Story Arc"), field2: ("storyArcPart", "Story Arc Part"))
        case .creator:
            return (field1: ("creatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .joinEntityEvent:
            return (field1: ("event", "Event Name"), field2: ("eventPart", "Part"))
        }
    }
    
    var attributes: (field1: (attributes: String, displayName: String), field2: (attributes: String, displayName: String)) {
        switch self {
        case .joinEntityStoryArc:
            return (field1: ("name", "Story Arc"), field2: ("storyArcPart", "Story Arc Part"))
        case .creator:
            return (field1: ("creatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .joinEntityEvent:
            return (field1: ("name", "Event Name"), field2: ("eventPart", "Part"))
        }
    }

    var headerText: String {
        switch self {
        case .joinEntityStoryArc: return "Add an existing Story Arc"
        case .creator: return "Add an existing Creator Role"
        case .joinEntityEvent: return "Add an existing Event"
        }
    }
    
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        switch self {
        case .joinEntityStoryArc: return StoryArc.fetchRequest()
        case .joinEntityEvent: return Event.fetchRequest()
        case .creator: return Creator.fetchRequest() // Assuming you have a Creator entity
        }
    }
    
    var fieldTypes: (FieldType, FieldType) {
        switch self {
        case .joinEntityStoryArc:
            return (.string, .int16)
        case .creator:
            return (.string, .string)
        case .joinEntityEvent:
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
        case .joinEntityStoryArc:
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
        case .joinEntityEvent:
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
