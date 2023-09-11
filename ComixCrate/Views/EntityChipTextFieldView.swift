//
//  EntityChipTextFieldView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/10/23.
//

import SwiftUI

struct EntityChipTextFieldView: View {
    
    @Binding var book: Book
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    var type: ChipType
    var textType: TextFieldEntities
    
    @Binding var chips: [TempChipData]
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.eventName, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    private var bookStoryArcNames: [String] {
        (book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap { $0.storyArc?.storyArcName  } ?? []
    }
    
    private var eventName: [String] {
        (book.bookEvents as? Set<BookEvents>)?.compactMap { $0.events?.eventName } ?? []
    }
    
    //Bindings for EntityTextFieldView
    @State private var attribute1: String = ""
    @State private var attribute2: String = ""
    @State private var chipViewHeight: CGFloat = 10  // Initial value, can be adjusted
    @State private var editedStoryArcName: String
    @State private var editedStoryArcPart: String = ""
    @State private var editedEventName: String
    @State private var editedEventPart: String = ""
    
    init(book: Book, viewModel: EntityChipTextFieldViewModel, type: ChipType, textType: TextFieldEntities, chips: Binding<[TempChipData]>) {
        _book = .constant(book)
        self.type = type
        self.textType = textType
        let firstStoryArcName = (book.bookStoryArcs as? Set<StoryArc>)?.first?.storyArcName ?? ""
        _editedStoryArcName = State(initialValue: firstStoryArcName)
        let firstEventName = (book.bookEvents as? Set<Event>)?.first?.eventName ?? ""
        _editedEventName = State(initialValue: firstEventName)
        _chips = chips  // Assign the binding directly
    }
    
    var body: some View {
        
        var anyFetchedEntities: AnyFetchedResults {
            switch textType {
            case .bookStoryArcs:
                return AnyFetchedResults(allStoryArcs)
            case .bookCreatorRole:
                // Assuming you have a fetched results for bookCreatorRoles
                // return AnyFetchedResults(allBookCreatorRoles)
                fatalError("Fetched results for bookCreatorRoles not implemented yet")
            case .bookEvents:
                return AnyFetchedResults(allEvents)
            }
        }
        
        
        
        
        VStack {
            EntityTextFieldView(type: textType, chips: $chips, allEntities: anyFetchedEntities)
            ChipView(chips: $chips, editedAttribute1: $editedEventName, editedAttribute2: $editedEventPart, type: type, chipViewHeight: $chipViewHeight)
            Spacer(minLength: chipViewHeight)
        }
        .animation(.easeInOut, value: chips)
    }
}

class EntityChipTextFieldViewModel: ObservableObject {
    @Published var chips: [TempChipData] = []
    @Published var editedAttribute1: String = ""
    @Published var editedAttribute2: String = ""
    // ... other properties ...
    
    func addChip() {
        // Logic to add a chip
    }
    
    func editChip(chip: TempChipData) {
        // Logic to edit a chip and populate text fields
    }
    
    func deleteChip(chip: TempChipData) {
        // Logic to delete a chip
    }
}
