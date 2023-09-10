//
//  EditBookView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/3/23.
//

import SwiftUI
import CoreData

struct EditBookView: View {
    
    // MARK: - Properties
    @Binding var book: Book
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.eventName, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    @FetchRequest(entity: Book.entity(), sortDescriptors: [])
    private var bookItems: FetchedResults<Book>
    var viewModel: EntityChipTextFieldViewModel = EntityChipTextFieldViewModel()
    
    @State private var showAlert: Bool = false
    
    @State private var chips: [TempChipData] = []
    private var bookStoryArcNames: [String] {
        (book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap { $0.storyArc?.storyArcName  } ?? []
    }
    
    private var eventName: [String] {
        (book.bookEvents as? Set<BookEvents>)?.compactMap { $0.events?.eventName } ?? []
    }
    
    @State private var editedTitle: String
    @State private var editedIssueNumber: String
    @State private var editedStoryArcName: String
    @State private var editedStoryArcPart: String = ""
    @State private var editedReadPercentage: Double = 0.0
    @State private var editedEventName: String
    @State private var editedEventPart: String = ""
    
    @State private var chipViewHeight: CGFloat = 10  // Initial value, can be adjusted
    
    var onDelete: (() -> Void)? = nil
    
    //Bindings for EntityTextFieldView
    @State private var attribute1: String = ""
    @State private var attribute2: String = ""
    
    // MARK: - Initializer
    init(book: Book) {
        _book = .constant(book)
        _editedTitle = State(initialValue: book.title ?? "")
        _editedIssueNumber = State(initialValue: "\(book.issueNumber)")
        _editedReadPercentage = State(initialValue: book.read)
        let firstStoryArcName = (book.bookStoryArcs as? Set<StoryArc>)?.first?.storyArcName ?? ""
        _editedStoryArcName = State(initialValue: firstStoryArcName)
        let firstEventName = (book.bookEvents as? Set<Event>)?.first?.eventName ?? ""
        _editedEventName = State(initialValue: firstEventName)
        
        
        // Populate the chips array with existing story arcs from the book
        let existingStoryArcs: [TempChipData] = (book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap {
            let entityType = String(describing: type(of: $0).self) // This will give "BookStoryArcs"
            return TempChipData(entity: entityType, tempValue1: $0.storyArc?.storyArcName ?? "", tempValue2: ValueData.int16($0.storyArcPart))
        } ?? []
        
        // Populate the chips array with existing events from the book
        let existingEvents: [TempChipData] = (book.bookEvents as? Set<BookEvents>)?.compactMap {
            let entityType = String(describing: type(of: $0).self) // This will give "BookEvents"
            return TempChipData(entity: entityType, tempValue1: $0.events?.eventName ?? "", tempValue2: ValueData.int16($0.eventPart))
        } ?? []
        
        _chips = State(initialValue: existingStoryArcs + existingEvents) // Combine both arrays
        print("Existing story arcs: \(existingStoryArcs)")
    }
    
    
    var editedReadPercentageString: Binding<String> {
        Binding<String>(
            get: {
                String(self.editedReadPercentage)
            },
            set: {
                if let value = Double($0) {
                    self.editedReadPercentage = value
                }
            }
        )
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $editedTitle)
                TextField("Issue Number", text: $editedIssueNumber)
                TextField("Read Percent", text: editedReadPercentageString)
                    .keyboardType(.numberPad)
//                HStack(alignment: .top) {
//                    VStack(alignment: .leading) {
//                        Section(header: Text("Story Arcs")) {
//                            VStack(alignment: .leading) {
//                                VStack(alignment: .leading) {
//                                    EntityTextFieldView(entityType: .bookStoryArc($editedStoryArcName, $editedStoryArcPart, .string, .int16), chips: $chips, allEntities: AnyFetchedResults(allStoryArcs))
//                                }
//                                ScrollView {
//                                    ChipView(chips: $chips, editedAttribute1: $editedStoryArcName, editedAttribute2: $editedStoryArcPart, type: .storyArc, chipViewHeight: $chipViewHeight)
//                                        .padding(.vertical, 15)
//                                        .frame(height: chipViewHeight)
//                                }
//                            }
//                        }
//                    }
//                    VStack {
//                        Section(header: Text("Events")) {
//                            VStack {
//                                VStack {
//                                    EntityTextFieldView(entityType: .bookEvents($editedEventName, $editedEventPart, .string, .int16), chips: $chips, allEntities: AnyFetchedResults(allEvents))
//                                }
//                                VStack {
//                                    ChipView(chips: $chips, editedAttribute1: $editedEventName, editedAttribute2: $editedEventPart, type: .bookEvents, chipViewHeight: $chipViewHeight)
//                                        .padding(.vertical, 15)
//                                        .frame(height: chipViewHeight)
//                                }
//                            }
//                        }
//                    }
//                }
                
                Section(header: Text("Testing New View")) {
                    HStack(alignment: .top) {
                        EntityChipTextFieldView(book: book, viewModel: viewModel, type: .storyArc, chips: $chips)
                        Divider()
                        EntityChipTextFieldView(book: book, viewModel: viewModel, type: .bookEvents, chips: $chips)
                    }
                }
            }
            .onAppear {
                printAllTempChipData()
            }
            HStack {
                Spacer()
                Button("Save") {
                    saveChanges()
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel") {
                    showAlert = true
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Are you sure?"),
                          message: Text("Any changes will not be saved."),
                          primaryButton: .destructive(Text("Don't Save")) {
                        presentationMode.wrappedValue.dismiss()
                    },
                          secondaryButton: .cancel())
                }
                .foregroundColor(.gray)
                
                Spacer()
            }
            .padding()
        }
    }
    
}

// MARK: - EditBookView Extensions
extension EditBookView {
    
    // MARK: - Helper Functions
    func printAllTempChipData() {
        for chip in chips {
            print("Entity: \(chip.entity), Value1: \(chip.tempValue1), Value2: \(chip.tempValue2)")
        }
    }
    
    func filterStoryArcs() -> [StoryArc] {
        let query = editedStoryArcName.lowercased()
        return allStoryArcs.filter { ($0.storyArcName?.lowercased().contains(query) ?? false) }
    }
    
    func filterEvents() -> [Event] {
        let query = editedEventName.lowercased()
        return allEvents.filter { ($0.eventName?.lowercased().contains(query) ?? false) }
    }
    
    func saveChanges() {
        printAllTempChipData()
        print("Current book title: \(book.title ?? "nil")")
        print("Edited title: \(editedTitle)")
        if book.title != editedTitle {
            book.title = editedTitle
        }
        
        book.title = editedTitle
        book.issueNumber = Int16(editedIssueNumber) ?? 0
        
        // Clear existing associations for the book based on ChipType
        clearExistingAssociations(for: .storyArc, from: book)
        clearExistingAssociations(for: .bookEvents, from: book)
        clearExistingAssociations(for: .creator, from: book)
        
        // For each chip in the chips array
        for chip in chips {
            saveChip(chip)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving edited book: \(error)")
        }
    }
    
    func clearExistingAssociations(for type: ChipType, from book: Book) {
        switch type {
        case .storyArc:
            if let existingBookStoryArcs = book.bookStoryArcs as? Set<BookStoryArcs> {
                for bookStoryArc in existingBookStoryArcs {
                    viewContext.delete(bookStoryArc)
                }
            }
        case .bookEvents:
            if let existingBookEvents = book.bookEvents as? Set<Event> {
                for bookEvents in existingBookEvents {
                    viewContext.delete(bookEvents)
                }
            }        case .creator:
            if let existingBookCreators = book.bookCreatorRoles as? Set<Creator> {
                for bookCreator in existingBookCreators {
                    viewContext.delete(bookCreator)
                }
            }
        }
    }
    func saveChip(_ chip: TempChipData) {
        switch ChipType(rawValue: chip.entity) {
        case .storyArc:
            saveStoryArcChip(chip)
        case .bookEvents:
            saveEventChip(chip)
        case .creator:
            print("save creator chip")
        default:
            print("Unknown chip type")
        }
    }
    
    func saveStoryArcChip(_ chip: TempChipData) {
        let storyArcName = chip.tempValue1
        let partNumber: Int16?
        switch chip.tempValue2 {
        case .string(_):
            partNumber = nil
        case .int16(let intValue):
            partNumber = intValue
        }
        
        // Check if a StoryArc with the story arc name already exists globally
        let storyArc: StoryArc
        if let existingStoryArc = allStoryArcs.first(where: { $0.storyArcName?.lowercased() == storyArcName.lowercased() }) {
            storyArc = existingStoryArc
        } else {
            // If the StoryArc doesn't exist, create a new one
            storyArc = StoryArc(context: viewContext)
            storyArc.storyArcName = storyArcName
        }
        
        // Create a new BookStoryArcs record to associate the book with the story arc
        let bookStoryArc = BookStoryArcs(context: viewContext)
        bookStoryArc.book = book
        bookStoryArc.storyArc = storyArc  // Assign the StoryArc object, not the name
        if let validPartNumber = partNumber {
            bookStoryArc.storyArcPart = validPartNumber
        } else {
            // Handle the case where partNumber is nil
            bookStoryArc.storyArcPart = 0 // or any default value you want
        }
    }
    func saveEventChip(_ chip: TempChipData) {
        let eventName = chip.tempValue1
        let partNumber: Int16?
        switch chip.tempValue2 {
        case .string(_):
            partNumber = nil
        case .int16(let intValue):
            partNumber = intValue
        }
        
        // Check if an Event with the event name already exists globally
        let event: Event
        if let existingEvent = allEvents.first(where: { $0.eventName?.lowercased() == eventName.lowercased() }) {
            event = existingEvent
        } else {
            // If the Event doesn't exist, create a new one
            event = Event(context: viewContext)
            event.eventName = eventName
        }
        
        // Check if a BookEvents association already exists for the current book and event
        if let existingBookEvent = (book.bookEvents as? Set<BookEvents>)?.first(where: { $0.events == event }) {
            // Update the existing association if necessary
            if let validPartNumber = partNumber {
                existingBookEvent.eventPart = validPartNumber
            } else {
                existingBookEvent.eventPart = 0 // or any default value you want
            }
        } else {
            // Create a new BookEvents record to associate the book with the event
            let bookEvent = BookEvents(context: viewContext)
            bookEvent.books = book
            bookEvent.events = event
            if let validPartNumber = partNumber {
                bookEvent.eventPart = validPartNumber
            } else {
                bookEvent.eventPart = 0 // or any default value you want
            }
        }
    }
}

// MARK: - TempChipData Struct
struct TempChipData: Identifiable {
    var id: UUID = UUID()
    var entity: String
    var tempValue1: String
    var tempValue2: ValueData
}

extension TempChipData: Equatable {
    static func == (lhs: TempChipData, rhs: TempChipData) -> Bool {
        return lhs.id == rhs.id && lhs.tempValue1 == rhs.tempValue1 && lhs.tempValue2 == rhs.tempValue2
    }
}
extension TempChipData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(tempValue1)
        hasher.combine(tempValue2)
    }
}



enum TextFieldEntities {
    case bookStoryArc(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookCreatorRole(Binding<String>, Binding<String>, FieldType, FieldType)
    case bookEvents(Binding<String>, Binding<String>, FieldType, FieldType)
    
    
    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
        switch self {
        case .bookStoryArc:
            return (field1: ("storyArcName", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
        case .bookCreatorRole:
            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
        case .bookEvents:
            return (field1: ("bookEventName", "Event Name"), field2: ("bookEventPart", "Part"))
        }
    }
    
    var headerText: String {
        switch self {
        case .bookStoryArc:
            return "Add an existing Story Arc"
        case .bookCreatorRole:
            return "Add an existing Creator Role"
        case .bookEvents:
            return "Add an existing Event"
        }
    }
    
    var bindings: (Binding<String>, Binding<String>) {
        switch self {
        case .bookStoryArc(let binding1, let binding2, _, _):
            return (binding1, binding2)
        case .bookCreatorRole(let binding1, let binding2, _, _):
            return (binding1, binding2)
        case .bookEvents(let binding1, let binding2, _, _):
            return (binding1, binding2)
        }
    }
    
    var fieldTypes: (FieldType, FieldType) {
        switch self {
        case .bookStoryArc(_, _, let type1, let type2):
            return (type1, type2)
        case .bookCreatorRole(_, _, let type1, let type2):
            return (type1, type2)
        case .bookEvents(_, _, let type1, let type2):
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
    var chipType: ChipType {
        switch self {
        case .bookStoryArc:
            return .storyArc
        case .bookCreatorRole:
            return .creator
        case .bookEvents:
            return .bookEvents
        }
    }
}






//enum EntitySection {
//    case storyArc
//    case event
//    // Add other entities as needed
//
//    var headerText: String {
//        switch self {
//        case .storyArc: return "Story Arcs"
//        case .event: return "Events"
//        }
//    }
//
//    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
//        switch self {
//        case .storyArc: return StoryArc.fetchRequest()
//        case .event: return Event.fetchRequest()
//        }
//    }
//
//    var sortDescriptorKeyPath: AnyKeyPath {
//        switch self {
//        case .storyArc: return \StoryArc.storyArcName
//        case .event: return \Event.eventName
//        }
//    }
//
//    var chipType: ChipType {
//        switch self {
//        case .storyArc: return .storyArc
//        case .event: return .bookEvents
//        }
//    }
//
//    var editedAttribute1: Binding<String> {
//        switch self {
//        case .storyArc: return $editedStoryArcName
//        case .event: return $editedEventName
//        }
//    }
//
//    var editedAttribute2: Binding<String> {
//        switch self {
//        case .storyArc: return $editedStoryArcPart
//        case .event: return $editedEventPart
//        }
//    }
//
//    var entityType: EntityType {
//        switch self {
//        case .storyArc: return .bookStoryArc(editedAttribute1, editedAttribute2, .string, .int16)
//        case .event: return .bookEvents(editedAttribute1, editedAttribute2, .string, .int16)
//        }
//    }
//}
