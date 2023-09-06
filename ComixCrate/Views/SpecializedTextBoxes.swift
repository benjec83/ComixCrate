//
//  SpecializedTextBoxes.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/4/23.
//

import SwiftUI
import CoreData

protocol EntityProtocol: NSManagedObject { }

extension StoryArc: EntityProtocol { }
// Add other entities as needed

extension Event: EntityProtocol { }
// Add other entities as needed

struct AnyFetchedResults {
    private let _objects: () -> [EntityProtocol]
    
    init<T: EntityProtocol>(_ results: FetchedResults<T>) {
        _objects = { results.map { $0 } }
    }
    
    var objects: [EntityProtocol] {
        _objects()
    }
}
struct EntityTextFieldView: View {
    var entityType: TextFieldEntities
    @Binding var chips: [TempChipData]
    var allEntities: AnyFetchedResults
//    var placeholder: String = "Enter item..."

    @FocusState private var isTextFieldFocused: Bool
    @State private var showAllSuggestionsSheet: Bool = false

    // Computed property to get filtered entities based on the current input
    var filteredEntities: [NSManagedObject] {
        let lowercasedInput = entityType.bindings.0.wrappedValue.lowercased()
        // This filtering logic might need to be updated based on the actual attribute you're filtering on
        return allEntities.objects.filter { ($0.value(forKey: entityType.attributes.field1.attribute) as? String)?.lowercased().contains(lowercasedInput) == true }
            .prefix(5)  // Take only the first 5 results
            .map { $0 }
    }
    
    var body: some View {
        VStack {
            HStack {
                // TextField for the first attribute (e.g., storyArcName, bookCreatorName, etc.)
                TextField(entityType.attributes.field1.displayName, text: entityType.bindings.0, onCommit: {
                    if let firstSuggestion = filteredEntities.first {
                        entityType.bindings.0.wrappedValue = firstSuggestion.value(forKey: entityType.attributes.field1.attribute) as? String ?? ""
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.leading)
                .focused($isTextFieldFocused)
                
                // TextField for the second attribute (e.g., storyArcPart, bookCreatorRole, etc.)
                TextField(entityType.attributes.field2.displayName, text: entityType.bindings.1)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .keyboardType(entityType.keyboardTypeForField2)  // Use the computed property here

                // "+" Button to add the new entity
                Button(action: {
                    // Check if the first attribute is not empty
                    guard !entityType.bindings.0.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        return
                    }
                    
                    let valueData: ValueData
                    switch entityType.fieldTypes.1 {
                    case .string:
                        valueData = .string(entityType.bindings.1.wrappedValue)
                    case .int16:
                        if let intValue = Int16(entityType.bindings.1.wrappedValue) {
                            valueData = .int16(intValue)
                        } else {
                            valueData = .int16(0) // or any default value you want
                        }
                    }

                    let newEntity = TempChipData(entity: entityType.attributes.field1.attribute, value1: entityType.bindings.0.wrappedValue, value2: valueData)
                    if !chips.contains(where: {
                        $0.value1 == newEntity.value1 && $0.value2 == newEntity.value2
                    }) {
                        chips.append(newEntity)
                    }
                    entityType.bindings.0.wrappedValue = ""
                    entityType.bindings.1.wrappedValue = ""
                    print("Adding new chip: \(newEntity)")
                    
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 30, height: 30) // Limit the button size
            }
            // Displaying filtered results
//            VStack(alignment: .leading) {
//                // Displaying filtered results
//                if isTextFieldFocused && !filteredEntities.isEmpty {
//                    ForEach(filteredEntities.indices, id: \.self) { index in
//                        let entity = filteredEntities[index]
//                        Text(entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? "")  // Use the unwrapped attribute value
//                            .padding(.vertical, 5)
//                            .onTapGesture {
//                                entityType.bindings.0.wrappedValue = entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? ""
//                                isTextFieldFocused = false
//                            }
//                    }
//                    .foregroundColor(.accentColor)
//                }
//                
//                Button("See All") {
//                    showAllSuggestionsSheet.toggle()
//                }
//                .buttonStyle(PlainButtonStyle())
//                .foregroundColor(.accentColor)
//                .padding(.top, 10)
//            }
            .sheet(isPresented: $showAllSuggestionsSheet) {  // Attach the .sheet modifier here
                Section(header: Text(entityType.headerText)) {
                List {
                    ForEach(allEntities.objects, id: \.objectID) { entity in
                        Button(action: {
                            // Update the text fields
                            entityType.bindings.0.wrappedValue = entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? ""
                            // Dismiss the sheet
                            showAllSuggestionsSheet = false
                        }) {
                            Text(entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? "")
                        }
                    }
                }
            }
            }

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


enum TextFieldEntities {
    case bookStoryArc(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookCreatorRole(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookEvent(Binding<String>, Binding<String>, FieldType, FieldType)
    
    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .bookStoryArc:
            return (field1: ("storyArcName", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
        case .bookCreatorRole:
            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvent:
            return (field1: ("bookEventName", "Event Name"), field2: ("bookEventPart", "Part"))
        }
    }
    
    var headerText: String {
        switch self {
        case .bookStoryArc:
            return "Add an existing Story Arc"
        case .bookCreatorRole:
            return "Add an existing Creator Role"
        case .bookEvent:
            return "Add an existing Event"
        }
    }
    
    var bindings: (Binding<String>, Binding<String>) {
        switch self {
        case .bookStoryArc(let binding1, let binding2, _, _):
            return (binding1, binding2)
        case .bookCreatorRole(let binding1, let binding2, _, _):
            return (binding1, binding2)
        case .bookEvent(let binding1, let binding2, _, _):
            return (binding1, binding2)
        }
    }
    
    var fieldTypes: (FieldType, FieldType) {
        switch self {
        case .bookStoryArc(_, _, let type1, let type2):
            return (type1, type2)
        case .bookCreatorRole(_, _, let type1, let type2):
            return (type1, type2)
        case .bookEvent(_, _, let type1, let type2):
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


