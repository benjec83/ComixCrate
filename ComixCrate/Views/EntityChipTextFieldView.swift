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
    @ObservedObject var viewModel: SelectedBookViewModel

    
    var type: EntityType
    
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
    
    init(book: Book, viewModel: SelectedBookViewModel, type: EntityType, chips: Binding<[TempChipData]>) {
        _book = .constant(book)
        self.viewModel = viewModel
        self.type = type
        let firstStoryArcName = (book.bookStoryArcs as? Set<StoryArc>)?.first?.storyArcName ?? ""
        _editedStoryArcName = State(initialValue: firstStoryArcName)
        let firstEventName = (book.bookEvents as? Set<Event>)?.first?.eventName ?? ""
        _editedEventName = State(initialValue: firstEventName)
        _chips = chips  // Assign the binding directly
    }
    
    var body: some View {
        
        var anyFetchedEntities: AnyFetchedResults {
            switch type {
            case .bookStoryArc :
                return AnyFetchedResults(allStoryArcs)
            case .creator :
                // Assuming you have a fetched results for bookCreatorRoles
                // return AnyFetchedResults(allBookCreatorRoles)
                fatalError("Fetched results for bookCreatorRoles not implemented yet")
            case .bookEvents:
                return AnyFetchedResults(allEvents)
            }
        }

        VStack {
            EntityTextFieldView(viewModel: viewModel, type: type, chips: $chips, allEntities: anyFetchedEntities)
            ChipView(viewModel: viewModel, chips: $chips, type: type, chipViewHeight: $chipViewHeight)

            Spacer(minLength: chipViewHeight)
        }
        .animation(.easeInOut, value: chips)
    }
}
