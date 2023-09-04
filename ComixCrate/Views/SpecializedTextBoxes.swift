//
//  SpecializedTextBoxes.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/4/23.
//

import SwiftUI

struct StoryArcTextFieldView: View {
    @Binding var storyArcName: String
    @Binding var storyArcPart: String
    @Binding var chips: [TempChipData]
    var allStoryArcs: FetchedResults<StoryArc>
    var placeholder: String = "Enter item..."
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var showAllSuggestionsSheet: Bool = false
    
    // Computed property to get filtered story arcs based on the current input
    var filteredStoryArcs: [StoryArc] {
        let lowercasedInput = storyArcName.lowercased()
        return allStoryArcs.filter { $0.storyArcName!.lowercased().contains(lowercasedInput) }
            .prefix(5)  // Take only the first 5 results
            .map { $0 }
    }
    
    var body: some View {
        VStack {
            HStack {
                // TextField for Story Arc Name
                TextField("Story Arc Name", text: $storyArcName, onCommit: {
                    if let firstSuggestion = filteredStoryArcs.first {
                        storyArcName = firstSuggestion.storyArcName!
                    }
                })
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.leading)
                .focused($isTextFieldFocused)
                
                // TextField for Story Arc Part
                TextField("Part #", text: $storyArcPart)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.leading)
                    .keyboardType(.numberPad) // Since it's a part number, we can use a number pad
                
                // "+" Button to add the new story arc and part #
                Button(action: {
                    // Check if storyArcName is not empty
                    guard !storyArcName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        return
                    }
                    
                    let partNumber = Int16(storyArcPart)
                    let newArc = TempChipData(type: "StoryArc", name: storyArcName, part: partNumber == 0 ? nil : partNumber)
                    if !chips.contains(where: { $0.name == newArc.name && $0.part == newArc.part }) {
                        chips.append(newArc)
                    }
                    storyArcName = ""
                    storyArcPart = ""
                    print("Adding new chip: \(newArc)")
                    
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 30, height: 30) // Limit the button size
                
            }
            // Displaying filtered results
            VStack(alignment: .leading) {
                // Displaying filtered results
                if isTextFieldFocused && !filteredStoryArcs.isEmpty {
                    ForEach(filteredStoryArcs.indices, id: \.self) { index in
                        let arc = filteredStoryArcs[index]
                        Text(arc.storyArcName!)  // Use the unwrapped storyArcName
                            .padding(.vertical, 5)
                            .onTapGesture {
                                storyArcName = arc.storyArcName!
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
                List(allStoryArcs, id: \.self) { storyArc in
                    Button(action: {
                        // Update the text fields
                        storyArcName = storyArc.storyArcName ?? ""
                        // Dismiss the sheet
                        showAllSuggestionsSheet = false
                    }) {
                        Text(storyArc.storyArcName ?? "")
                    }
                }
            }
        }
    }
}

