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
    
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.eventName, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    @FetchRequest(entity: Book.entity(), sortDescriptors: [])
    private var bookItems: FetchedResults<Book>

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
    init(book: Book, viewModel: SelectedBookViewModel, context: NSManagedObjectContext) {
        self.viewModel = viewModel
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

                
                
                Section(header: Text("Testing New View")) {
                    HStack(alignment: .top) {

                        EntityChipTextFieldView(book: book, viewModel: viewModel, type: .bookStoryArc, chips: $chips)
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
        
        // Clear existing associations for the book based on EntityType
        clearExistingAssociations(for: .bookStoryArc, from: book)
        print("After clearing story arcs: \(book.bookStoryArcs?.count ?? 0) arcs")
        clearExistingAssociations(for: .bookEvents, from: book)
        print("After clearing events: \(book.bookEvents?.count ?? 0) events")
        clearExistingAssociations(for: .creator, from: book)
        print("After clearing creators: \(book.bookCreatorRole?.count ?? 0) creators")

        // For each chip in the chips array
        for chip in chips {
            saveChip(chip)
        }
        
        do {
            try viewContext.save()
            // Fetch the book again and print its associated story arcs and events to ensure changes are persisted
            if let savedBook = bookItems.first(where: { $0 == book }) {
                print("After saving: \(savedBook.bookStoryArcs?.count ?? 0) story arcs")
                print("After saving: \(savedBook.bookEvents?.count ?? 0) events")
            }
        } catch {
            print("Error saving edited book: \(error)")
        }
    }
    
    func clearExistingAssociations(for type: EntityType, from book: Book) {
        switch type {
        case .bookStoryArc:
            if let existingBookStoryArcs = book.bookStoryArcs as? Set<BookStoryArcs> {
                for bookStoryArc in existingBookStoryArcs {
                    viewContext.delete(bookStoryArc)
                }
            }
        case .bookEvents:
            if let existingBookEvents = book.bookEvents as? Set<BookEvents> {
                for bookEvents in existingBookEvents {
                    viewContext.delete(bookEvents)
                }
            }        case .creator:
            if let existingBookCreators = book.bookCreatorRole as? Set<BookCreatorRole> {
                for bookCreator in existingBookCreators {
                    viewContext.delete(bookCreator)
                }
            }
        }
    }
    func saveChip(_ chip: TempChipData) {
         switch EntityType(rawValue: chip.entity) {
         case .bookStoryArc:
             saveStoryArcChip(chip)
             print("After saving story arc chip: \(book.bookStoryArcs?.count ?? 0)") // Added print statement
         case .bookEvents:
             saveEventChip(chip)
             print("After saving event chip: \(book.bookEvents?.count ?? 0)") // Added print statement
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

//// MARK: Preview
//#if DEBUG
//struct EditBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditBookView(book: createSampleBook(using: PreviewCoreDataManager.shared.container.viewContext))
//    }
//}
//#endif


//#if DEBUG
//struct EditBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        Text("Hello, World!")
//    }
//}
//#endif


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
