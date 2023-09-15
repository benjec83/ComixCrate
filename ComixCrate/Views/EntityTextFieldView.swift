//
//  EntityTextFieldView.swift
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
    @ObservedObject var viewModel: SelectedBookViewModel
    private var bindings: (Binding<String>, Binding<String>) {
        type.bindings(from: viewModel)
    }


    var type: EntityType
    @Binding var chips: [TempChipData]
    var allEntities: AnyFetchedResults
    var placeholder: String = "Enter item..."
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAllSuggestionsSheet: Bool = false
    
    
//    // Computed property to get filtered entities based on the current input
//    var filteredEntities: [NSManagedObject] {
//        let lowercasedInput = bindings.0.wrappedValue.lowercased()
//        // This filtering logic might need to be updated based on the actual attributes you're filtering on
//        return allEntities.objects.filter { ($0.value(forKey: type.attributes.field1.attributes) as? String)?.lowercased().contains(lowercasedInput) == true }
//            .prefix(5)  // Take only the first 5 results
//            .map { $0 }
//    }
    
    var body: some View {
        VStack {
            HStack {
                // TextField for the first attributes (e.g., storyArcName, bookCreatorName, etc.)
                TextField(type.attributes.field1.displayName, text: type.bindings(from: viewModel).0, onCommit: {
                    if let firstSuggestion = viewModel.filteredEntities.first {
                        bindings.0.wrappedValue = firstSuggestion.value(forKey: type.attributes.field1.attributes) as? String ?? ""
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.leading)
                .focused($isTextFieldFocused)
                
                // TextField for the second attributes (e.g., storyArcPart, bookCreatorRole, etc.)
                TextField(type.attributes.field2.displayName, text: type.bindings(from: viewModel).1)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .keyboardType(type.keyboardTypeForField2)  // Use the computed property here
                
                // "+" Button to add the new entity
                Button(action: {
                    // Check if the first attributes is not empty
                    guard !type.bindings(from: viewModel).0.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        return
                    }
                    
                    let valueData: ValueData
                    switch type.fieldTypes.1 {
                    case .string:
                        valueData = .string(bindings.1.wrappedValue)
                        print(type)
                    case .int16:
                        if let intValue = Int16(bindings.1.wrappedValue) {
                            valueData = .int16(intValue)
                            print(type)
                        } else {
                            valueData = .int16(0) // or any default value you want
                            print(type)
                            
                        }
                    }
                    
                    let newEntity = TempChipData(entity: type.rawValue, tempValue1: bindings.0.wrappedValue, tempValue2: valueData)
                    if !chips.contains(where: {
                        $0.tempValue1 == newEntity.tempValue1 && $0.tempValue2 == newEntity.tempValue2
                    }) {
                        chips.append(newEntity)
                    }
                    bindings.0.wrappedValue = ""
                    bindings.1.wrappedValue = ""
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
                if isTextFieldFocused && !viewModel.filteredEntities.isEmpty {
                    ForEach(viewModel.filteredEntities.indices, id: \.self) { index in
                        let entity = viewModel.filteredEntities[index]
                        Text(entity.value(forKey: type.attributes.field1.attributes) as? String ?? "")  // Use the unwrapped attributes value
                            .padding(.vertical, 5)
                            .onTapGesture {
                                bindings.0.wrappedValue = entity.value(forKey: type.attributes.field1.attributes) as? String ?? ""
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
                                bindings.0.wrappedValue = entity.value(forKey: type.attributes.field1.attributes) as? String ?? ""
                                // Dismiss the sheet
                                showAllSuggestionsSheet = false
                            }) {
                                Text(entity.value(forKey: type.attributes.field1.attributes) as? String ?? "")
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
