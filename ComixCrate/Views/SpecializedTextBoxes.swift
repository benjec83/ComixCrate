//
//  SpecializedTextBoxes.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/4/23.
//

import SwiftUI
import CoreData

protocol EntityProtocol: NSManagedObject { }

//extension StoryArc: EntityProtocol { }
//// Add other entities as needed
//
//extension Event: EntityProtocol { }
//// Add other entities as needed

extension NSManagedObject: EntityProtocol { }


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
    var type: TextFieldEntities
    @Binding var chips: [TempChipData]
    var allEntities: AnyFetchedResults
    var placeholder: String = "Enter item..."
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAllSuggestionsSheet: Bool = false
    
    // Computed property to get filtered entities based on the current input
    var filteredEntities: [NSManagedObject] {
        let lowercasedInput = type.bindings.0.wrappedValue.lowercased()
        // This filtering logic might need to be updated based on the actual attribute you're filtering on
        return allEntities.objects.filter { ($0.value(forKey: type.attributes.field1.attribute) as? String)?.lowercased().contains(lowercasedInput) == true }
            .prefix(5)  // Take only the first 5 results
            .map { $0 }
    }
    
    var body: some View {
        VStack {
            HStack {
                // TextField for the first attribute (e.g., storyArcName, bookCreatorName, etc.)
                TextField(type.attributes.field1.displayName, text: type.bindings.0, onCommit: {
                    if let firstSuggestion = filteredEntities.first {
                        type.bindings.0.wrappedValue = firstSuggestion.value(forKey: type.attributes.field1.attribute) as? String ?? ""
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.leading)
                .focused($isTextFieldFocused)
                
                // TextField for the second attribute (e.g., storyArcPart, bookCreatorRole, etc.)
                TextField(type.attributes.field2.displayName, text: type.bindings.1)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .keyboardType(type.keyboardTypeForField2)  // Use the computed property here
                
                // "+" Button to add the new entity
                Button(action: {
                    // Check if the first attribute is not empty
                    guard !type.bindings.0.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        return
                    }
                    
                    let valueData: ValueData
                    switch type.fieldTypes.1 {
                    case .string:
                        valueData = .string(type.bindings.1.wrappedValue)
                        print(type)
                    case .int16:
                        if let intValue = Int16(type.bindings.1.wrappedValue) {
                            valueData = .int16(intValue)
                            print(type)
                        } else {
                            valueData = .int16(0) // or any default value you want
                            print(type)
                            
                        }
                    }
                    
                    let newEntity = TempChipData(entity: type.chipType.rawValue, tempValue1: type.bindings.0.wrappedValue, tempValue2: valueData)
                    if !chips.contains(where: {
                        $0.tempValue1 == newEntity.tempValue1 && $0.tempValue2 == newEntity.tempValue2
                    }) {
                        chips.append(newEntity)
                    }
                    type.bindings.0.wrappedValue = ""
                    type.bindings.1.wrappedValue = ""
                    print("Adding new chip: \(newEntity)")
                    
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 30, height: 30) // Limit the button size
            }
            // MARK: Displaying filtered results
            VStack(alignment: .leading) {
                // Displaying filtered results
                if isTextFieldFocused && !filteredEntities.isEmpty {
                    ForEach(filteredEntities.indices, id: \.self) { index in
                        let entity = filteredEntities[index]
                        Text(entity.value(forKey: type.attributes.field1.attribute) as? String ?? "")  // Use the unwrapped attribute value
                            .padding(.vertical, 5)
                            .onTapGesture {
                                type.bindings.0.wrappedValue = entity.value(forKey: type.attributes.field1.attribute) as? String ?? ""
                                isTextFieldFocused = false
                            }
                    }
                    .foregroundColor(.accentColor)
                }
                
                Button("See All") {
                    showAllSuggestionsSheet.toggle()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.accentColor)
                .padding(.top, 10)
            }
            .sheet(isPresented: $showAllSuggestionsSheet) {  // Attach the .sheet modifier here
                Section(header: Text(type.headerText)) {
                    List {
                        ForEach(allEntities.objects, id: \.objectID) { entity in
                            Button(action: {
                                // Update the text fields
                                type.bindings.0.wrappedValue = entity.value(forKey: type.attributes.field1.attribute) as? String ?? ""
                                // Dismiss the sheet
                                showAllSuggestionsSheet = false
                            }) {
                                Text(entity.value(forKey: type.attributes.field1.attribute) as? String ?? "")
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
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

struct SpecializedTextBoxes_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let sampleBook = createSampleBook(using: PreviewCoreDataManager.shared.container.viewContext)

        // Sample bindings for the EntityTextFieldView
        let storyArcNameBinding = Binding<String>(
            get: { sampleBook.title ?? "" },
            set: { sampleBook.title = $0 }
        )
        
        let storyArcPartBinding = Binding<String>(
            get: { String(sampleBook.issueNumber) },
            set: { sampleBook.issueNumber = Int16($0) ?? 0 }
        )
        
        let eventNameBinding = Binding<String>(
            get: { sampleBook.title ?? "" },
            set: { sampleBook.title = $0 }
        )
        
        let eventPartBinding = Binding<String>(
            get: { String(sampleBook.issueNumber) },
            set: { sampleBook.issueNumber = Int16($0) ?? 0 }
        )
        
        // Fetch all entities (in this case, just the sample book)
        let fetchedResults: FetchedResults<Book> = FetchRequest<Book>(entity: Book.entity(), sortDescriptors: []).wrappedValue
        let anyFetchedResults = AnyFetchedResults(fetchedResults)
        
        return HStack {
            EntityTextFieldView(
                type: .bookStoryArcs(storyArcNameBinding, storyArcPartBinding, .string, .int16),
                chips: .constant([]),
                allEntities: anyFetchedResults
            )
            EntityTextFieldView(
                type: .bookEvents(eventNameBinding, eventPartBinding, .string, .int16),
                chips: .constant([]),
                allEntities: anyFetchedResults
            )
        }
        .environment(\.managedObjectContext, context)
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


