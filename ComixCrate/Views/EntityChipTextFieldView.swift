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
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.name, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    private var bookStoryArcNames: [String] {
            let names = (book.arcJoins as? Set<JoinEntityStoryArc>)?.compactMap { $0.storyArc?.name  } ?? []
            if names.isEmpty {
                print("Error: Failed to fetch bookStoryArcNames or no names found.")
            }
            return names
        }
        
        private var eventName: [String] {
            let names = (book.eventJoins as? Set<JoinEntityEvent>)?.compactMap { $0.events?.name } ?? []
            if names.isEmpty {
                print("Error: Failed to fetch event names or no names found.")
            }
            return names
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
            let firstStoryArcName = (book.arcJoins as? Set<StoryArc>)?.first?.name ?? ""
            if firstStoryArcName.isEmpty {
                print("Error: Failed to fetch the first story arc name. Init Message")
            }
            _editedStoryArcName = State(initialValue: firstStoryArcName)
            let firstEventName = (book.eventJoins as? Set<Event>)?.first?.name ?? ""
            if firstEventName.isEmpty {
                print("Error: Failed to fetch the first event name. Init Message")
            }
            _editedEventName = State(initialValue: firstEventName)
            _chips = chips  // Assign the binding directly
        }
        
        var body: some View {
            
            var anyFetchedEntities: AnyFetchedResults {
                switch type {
                case .joinEntityStoryArc :
                    if allStoryArcs.isEmpty {
                        print("Error: No story arcs found in fetched results.")
                    }
                    return AnyFetchedResults(allStoryArcs)
                case .creator :
                    // Assuming you have a fetched results for bookCreatorRoles
                    // return AnyFetchedResults(allBookCreatorRoles)
                    fatalError("Fetched results for bookCreatorRoles not implemented yet")
                case .joinEntityEvent:
                    if allEvents.isEmpty {
                        print("Error: No events found in fetched results.")
                    }
                    return AnyFetchedResults(allEvents)
                }
            }

        VStack {
//            ChipView(viewModel: viewModel, chips: $chips, type: type, chipViewHeight: $chipViewHeight)
//            Spacer(minLength: chipViewHeight)
////            EntityInputView(viewModel: viewModel, type: type, chips: $chips, allEntities: anyFetchedEntities)
////                .padding(.top, 25)
//            EntityTextFieldView(viewModel: viewModel, type: .joinEntityEvent, chips: $chips, allEntities: anyFetchedEntities, placeholder: "Enter item...")

        }
        .animation(.easeInOut, value: chips)
    }
}
