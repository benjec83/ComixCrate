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
    @ObservedObject var viewModel: SelectedBookViewModel
    
    @Binding var book: Book
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.name, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    @FetchRequest(entity: Book.entity(), sortDescriptors: [])
    private var bookItems: FetchedResults<Book>
    
    @State private var showAlert: Bool = false
    
    @State private var chips: [TempChipData] = []
    private var bookStoryArcNames: [String] {
        (book.arcJoins as? Set<JoinEntityStoryArc>)?.compactMap { $0.storyArc?.name  } ?? []
    }
    
    private var eventName: [String] {
        (book.eventJoins as? Set<JoinEntityEvent>)?.compactMap { $0.events?.name } ?? []
    }
    
    @State private var editedTitle: String
    @State private var editedIssueNumber: String
    @State private var editedStoryArcName: String
    @State private var editedStoryArcPart: String = ""
    @State private var editedReadPercentage: Decimal = 0.0
    @State private var editedEventName: String
    @State private var editedEventPart: String = ""
    @State private var editedSeriesVolume: String
    @State private var editedSeries: String = ""
    @State private var editedSummary: String = ""
    
    
    
    
    @State private var chipViewHeight: CGFloat = 10  // Initial value, can be adjusted
    
    var onDelete: (() -> Void)? = nil
    
    //Bindings for EntityTextFieldView
    @State private var attribute1: String = ""
    @State private var attribute2: String = ""
    
    // MARK: - Initializer
    init(book: Book, viewModel: SelectedBookViewModel, context: NSManagedObjectContext) {
        self.viewModel = viewModel
        _book = .constant(book)
        _editedTitle = State(initialValue: book.title ?? "")
        _editedIssueNumber = State(initialValue: "\(book.issueNumber)")
        _editedSummary = State(initialValue: book.summary ?? "")
        _editedSeries = State(initialValue: book.bookSeries?.name ?? "")
        _editedReadPercentage = State(initialValue: book.read?.decimalValue ?? Decimal(0))
        let firstStoryArcName = (book.arcJoins as? Set<StoryArc>)?.first?.name ?? ""
        _editedStoryArcName = State(initialValue: firstStoryArcName)
        let firstEventName = (book.eventJoins as? Set<JoinEntityEvent>)?.first?.events?.name ?? ""
        _editedEventName = State(initialValue: firstEventName)
        _editedSeriesVolume = State(initialValue: "\(book.volumeYear)")
        
        // Populate the chips array with existing story arcs from the book
        let existingStoryArcs: [TempChipData] = (book.arcJoins as? Set<JoinEntityStoryArc>)?.compactMap {
            let entityType = String(describing: type(of: $0).self) // This will give "BookStoryArcs"
            return TempChipData(entity: entityType, tempValue1: $0.storyArc?.name ?? "", tempValue2: ValueData.int16($0.storyArcPart))
        } ?? []
        
        // Populate the chips array with existing events from the book
        let existingEvents: [TempChipData] = (book.eventJoins as? Set<JoinEntityEvent>)?.compactMap {
            let entityType = String(describing: type(of: $0).self) // This will give "BookEvents"
            return TempChipData(entity: entityType, tempValue1: $0.events?.name ?? "", tempValue2: ValueData.int16($0.eventPart))
        } ?? []
        
        _chips = State(initialValue: existingStoryArcs + existingEvents) // Combine both arrays
        print("Existing story arcs: \(existingStoryArcs)")
        print("Existing events: \(existingEvents)")
        
    }
    
    
    var editedReadPercentageString: Binding<String> {
        Binding<String>(
            get: {
                "\(self.editedReadPercentage)"
            },
            set: {
                if let value = Decimal(string: $0) {
                    self.editedReadPercentage = value
                }
            }
        )
    }
    
    
    
    // MARK: - Body
    var body: some View {
        VStack {
            Form {
                HStack(spacing: 2) {
                    VStack(alignment: .leading) {
                        Section {
                            TextField("Title", text: $editedTitle)
                        }header: {
                            Text("Title")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Section {
                                TextField("Issue Number", text: $editedIssueNumber)
                                    .keyboardType(.numberPad)
                            }header: {
                                Text("Issue Number")
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        VStack(alignment: .leading) {
                            Section {
                                TextField("Volume Number", value: $editedSeriesVolume, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                            }header: {
                                Text("Volume Number")
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Section {
                        TextField("Add a Series", text: $editedSeries)
                    }header: {
                        Text("Series")
                            .multilineTextAlignment(.leading)
                    }
                }
                HStack(spacing: 2) {
                    VStack(alignment: .leading) {
                        Section {
                            EntityChipTextFieldView(book: book, viewModel: viewModel, type: .joinEntityStoryArc, chips: $chips)
                        }header: {
                            Text("Story Arcs")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    Spacer(minLength: 10)
                    VStack(alignment: .leading) {
                        Section {
                            EntityChipTextFieldView(book: book, viewModel: viewModel, type: .joinEntityEvent, chips: $chips)
                        }header: {
                            Text("Events")
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Section {
                        TextEditor(text: $editedSummary)
                            .frame(minHeight: 150, alignment: .top)
                    }header: {
                        Text("Summary")
                    }
                }
                TextField("Read Percent", text: editedReadPercentageString)
                    .keyboardType(.numberPad)
                
                Section {
                    ChipView(viewModel: viewModel, chips: $chips, type: .creator, chipViewHeight: $chipViewHeight)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Section {
                                Text("$editedCharacters")
                            }header: {
                                Text("Characters")
                            }
                        }
                        VStack(alignment: .leading) {
                            Section {
                                Text("$editedTeams")
                            }header: {
                                Text("Teams")
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        Section {
                            Text("$editedLocations")
                        }header: {
                            Text("Locations")
                        }
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
        return allStoryArcs.filter { ($0.name?.lowercased().contains(query) ?? false) }
    }
    
    func filterEvents() -> [Event] {
        let query = editedEventName.lowercased()
        return allEvents.filter { ($0.name?.lowercased().contains(query) ?? false) }
    }
    
    func saveChanges() {
        printAllTempChipData()
        if book.title != editedTitle {
            book.title = editedTitle
        }
        
        book.title = editedTitle
        book.issueNumber = Int16(editedIssueNumber) ?? 0
        book.read = NSDecimalNumber(decimal: editedReadPercentage)
        book.summary = editedSummary
        book.bookSeries?.name = editedSeries
        
        // Clear existing associations for the book based on EntityType
        clearExistingAssociations(for: .joinEntityStoryArc, from: book)
        print("After clearing story arcs: \(book.arcJoins?.count ?? 0) arcs")
        clearExistingAssociations(for: .joinEntityEvent, from: book)
        print("After clearing events: \(book.eventJoins?.count ?? 0) events")
        clearExistingAssociations(for: .creator, from: book)
        print("After clearing creators: \(book.creatorJoins?.count ?? 0) creators")
        
        // For each chip in the chips array
        for chip in chips {
            saveChip(chip)
        }
        
        do {
            try viewContext.save()
            // Fetch the book again and print its associated story arcs and events to ensure changes are persisted
            if let savedBook = bookItems.first(where: { $0 == book }) {
                print("After saving: \(savedBook.arcJoins?.count ?? 0) story arcs")
                print("After saving: \(savedBook.eventJoins?.count ?? 0) events")
            }
        } catch {
            print("Error saving edited book: \(error.localizedDescription)") // Added detailed error message
        }
    }
    
    func clearExistingAssociations(for type: EntityType, from book: Book) {
        switch type {
        case .joinEntityStoryArc:
            if let existingBookStoryArcs = book.arcJoins as? Set<JoinEntityStoryArc> {
                for bookStoryArc in existingBookStoryArcs {
                    viewContext.delete(bookStoryArc)
                }
            } else {
                print("Error: Failed to cast book.arcJoins to Set<JoinEntityStoryArc>") // Added error print statement
            }
        case .joinEntityEvent:
            if let existingJoinEntityEvent = book.eventJoins as? Set<JoinEntityEvent> {
                for joinEntityEvent in existingJoinEntityEvent {
                    viewContext.delete(joinEntityEvent)
                }
            } else {
                print("Error: Failed to cast book.eventJoins to Set<JoinEntityEvent>") // Added error print statement
            }
        case .creator:
            if let existingBookCreators = book.creatorJoins as? Set<JoinEntityCreator> {
                for bookCreator in existingBookCreators {
                    viewContext.delete(bookCreator)
                }
            } else {
                print("Error: Failed to cast book.creatorJoins to Set<JoinEntityCreator>") // Added error print statement
            }
        }
    }
    func saveChip(_ chip: TempChipData) {
        switch EntityType(rawValue: chip.entity) {
        case .joinEntityStoryArc:
            saveStoryArcChip(chip)
            print("After saving story arc chip: \(book.arcJoins?.count ?? 0)") // Added print statement
        case .joinEntityEvent:
            saveEventChip(chip)
            print("After saving event chip: \(book.eventJoins?.count ?? 0)") // Added print statement
        case .creator:
            print("save creator chip")
        default:
            print("Unknown chip type")
        }
    }
    
    func saveStoryArcChip(_ chip: TempChipData) {
        print("Running saveStoryArcChip")
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
        if let existingStoryArc = allStoryArcs.first(where: { $0.name?.lowercased() == storyArcName.lowercased() }) {
            storyArc = existingStoryArc
        } else {
            // If the StoryArc doesn't exist, create a new one
            storyArc = StoryArc(context: viewContext)
            storyArc.name = storyArcName
        }
        
        // Create a new BookStoryArcs record to associate the book with the story arc
        let bookStoryArc = JoinEntityStoryArc(context: viewContext)
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
        print("Running saveEventChip")
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
        if let existingEvent = allEvents.first(where: { $0.name?.lowercased() == eventName.lowercased() }) {
            event = existingEvent
        } else {
            // If the Event doesn't exist, create a new one
            event = Event(context: viewContext)
            event.name = eventName
        }
        
        // Create a new BookEvent record to associate the book with the event
        let bookEvent = JoinEntityEvent(context: viewContext)
        bookEvent.books = book
        bookEvent.events = event
        if let validPartNumber = partNumber {
            bookEvent.eventPart = validPartNumber
        } else {
            // Handle the case where partNumber is nil
            bookEvent.eventPart = 0
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
