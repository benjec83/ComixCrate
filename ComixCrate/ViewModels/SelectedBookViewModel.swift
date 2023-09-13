//
//  SelectedBookViewModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import Foundation
import SwiftUI
import CoreData

class SelectedBookViewModel: ObservableObject {
    @Published var book: Book
    @Published var userRating: Double
    @Published var isFavorite: Bool
    @Published var shouldCacheHighQualityThumbnail: Bool = false
    
    @Published var chips: [TempChipData] = []
    @Published var editedAttribute1: String = ""
    @Published var editedAttribute2: String = ""
    var type: EntityType
    var allEntities: AnyFetchedResults
    
    // Properties for edited attributes
    @Published var editedStoryArcName: String = ""
    @Published var editedStoryArcPart: String = ""
    @Published var editedEventName: String = ""
    @Published var editedEventPart: String = ""
    @Published var editedCreatorName: String = ""
    @Published var editedCreatorRole: String = ""
    
    private var viewContext: NSManagedObjectContext
    
    init(book: Book, context: NSManagedObjectContext, type: EntityType, allEntities: AnyFetchedResults) {
        self.book = book
        self.userRating = Double(book.personalRating) / 2.0
        self.isFavorite = book.isFavorite
        self.viewContext = context
        self.type = type
        self.allEntities = allEntities
    }

    var filteredEntities: [NSManagedObject] {
        let lowercasedInput = editedAttribute1.lowercased()
        return allEntities.objects.filter {
            ($0.value(forKey: type.attributes.field1.attribute) as? String)?.lowercased().contains(lowercasedInput) == true
        }
        .prefix(5)
        .map { $0 }
    }
    
    func markBookAsRead() {
        book.read = 100
        saveContext()
    }
    
    func markBookAsUnread() {
        book.read = 0
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to update read status: \(error)")
        }
    }
    
    func updateUserRating(to newRating: Double) {
        userRating = newRating
        book.personalRating = newRating
        saveContext()
    }
    
    func updateEditedAttributes(for chip: TempChipData) {
        switch EntityType(rawValue: chip.entity) {
        case .bookStoryArc:
            editedStoryArcName = chip.tempValue1
            switch chip.tempValue2 {
            case .string(let stringValue):
                editedStoryArcPart = stringValue
            case .int16(let intValue):
                editedStoryArcPart = "\(intValue)"
            }
        case .bookEvents:
            editedEventName = chip.tempValue1
            switch chip.tempValue2 {
            case .string(let stringValue):
                editedEventPart = stringValue
            case .int16(let intValue):
                editedEventPart = "\(intValue)"
            }
        case .creator:
            editedEventName = chip.tempValue1
            switch chip.tempValue2 {
            case .string(let stringValue):
                editedEventPart = stringValue
            case .int16(let intValue):
                editedEventPart = "\(intValue)"
            }
        default:
            break
        }
    }
    
    func addChip() {
        // ... (logic to add a chip)
    }
    
    func editChip(chip: TempChipData) {
        // ... (logic to edit a chip)
    }
    
    func deleteChip(chip: TempChipData) {
        // ... (logic to delete a chip)
    }
}

