//
//  EntityInputView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI
import CoreData

struct EntityInputView: View {
    @ObservedObject var viewModel: SelectedBookViewModel
    var type: EntityType  // <-- Change this to EntityType
    var allEntities: AnyFetchedResults
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAllSuggestionsSheet: Bool = false
    @State private var chipViewHeight: CGFloat = 0

    var body: some View {
        VStack {
            // Entity Input Section
            HStack {
                TextField(type.attributes.field1.displayName, text: $viewModel.editedAttribute1, onCommit: {
                    if let firstSuggestion = viewModel.filteredEntities.first {
                        viewModel.editedAttribute1 = firstSuggestion.value(forKey: type.attributes.field1.attribute) as? String ?? ""
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.leading)
                .focused($isTextFieldFocused)
                
                TextField(type.attributes.field2.displayName, text: $viewModel.editedAttribute2)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .keyboardType(type.keyboardTypeForField2)
                
                Button(action: viewModel.addChip) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 30, height: 30)
            }
            
            // Chip Display Section
            ChipView(viewModel: viewModel, chips: $viewModel.chips, type: type, chipViewHeight: $chipViewHeight)
        


            // Suggestions Section
            if isTextFieldFocused && !viewModel.filteredEntities.isEmpty {
                ForEach(viewModel.filteredEntities.indices, id: \.self) { index in
                    let entity = viewModel.filteredEntities[index]
                    Text(entity.value(forKey: type.attributes.field1.attribute) as? String ?? "")
                        .padding(.vertical, 5)
                        .onTapGesture {
                            viewModel.editedAttribute1 = entity.value(forKey: type.attributes.field1.attribute) as? String ?? ""
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
                            type.bindings(from: viewModel).0.wrappedValue = entity.value(forKey: type.attributes.field1.attribute) as? String ?? ""
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
