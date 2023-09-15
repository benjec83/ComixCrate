//
//  EntityInputViewModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import Foundation
import SwiftUI
import CoreData

class EntityInputViewModel: ObservableObject {
    @Published var chips: [TempChipData] = []
    @Published var editedAttribute1: String = ""
    @Published var editedAttribute2: String = ""
    // ... other properties ...
    
    var type: EntityType
    var allEntities: AnyFetchedResults

    init(type: EntityType, allEntities: AnyFetchedResults) {
        self.type = type
        self.allEntities = allEntities
    }
    
    var filteredEntities: [NSManagedObject] {
        let lowercasedInput = editedAttribute1.lowercased()
        return allEntities.objects.filter {
            ($0.value(forKey: type.attribute.field1.attribute) as? String)?.lowercased().contains(lowercasedInput) == true
        }
        .prefix(5)
        .map { $0 }
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
