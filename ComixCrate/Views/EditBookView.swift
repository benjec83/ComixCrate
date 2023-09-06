//
//  EditBookView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/3/23.
//

import SwiftUI
import CoreData

struct EditBookView: View {
    
    @Binding var book: Book
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.eventName, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    
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
            return TempChipData(entity: entityType, tempAttribute1: $0.storyArc?.storyArcName ?? "", tempAttribute2: ValueData.int16($0.storyArcPart))
        } ?? []

        // Populate the chips array with existing events from the book
        let existingEvents: [TempChipData] = (book.bookEvents as? Set<BookEvents>)?.compactMap {
            let entityType = String(describing: type(of: $0).self) // This will give "BookEvents"
            return TempChipData(entity: entityType, tempAttribute1: $0.events?.eventName ?? "", tempAttribute2: ValueData.int16($0.eventPart))
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
    
    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $editedTitle)
                TextField("Issue Number", text: $editedIssueNumber)
                TextField("Read Percent", text: editedReadPercentageString)
                    .keyboardType(.numberPad)
                
                Section(header: Text("Story Arcs")) {
                    ChipView(chips: $chips, editedAttribute1: $editedStoryArcName, editedAttribute2: $editedStoryArcPart, type: .storyArc, chipViewHeight: $chipViewHeight)
                    
                    EntityTextFieldView(entityType: .bookStoryArc($editedStoryArcName, $editedStoryArcPart, .string, .int16), chips: $chips, allEntities: AnyFetchedResults(allStoryArcs))
                }
                Section(header: Text("Events")) {
                    ChipView(chips: $chips, editedAttribute1: $editedEventName, editedAttribute2: $editedEventPart, type: .event, chipViewHeight: $chipViewHeight)
                        .padding(.vertical, 15)
                        .frame(height: chipViewHeight)
                    
                    EntityTextFieldView(entityType: .bookEvent($editedEventName, $editedEventPart, .string, .int16), chips: $chips, allEntities: AnyFetchedResults(allEvents))
                }
            }
            .onAppear {
                printAllTempChipData()
            }
            
            Spacer()
            
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

extension EditBookView {
    
    func printAllTempChipData() {
        for chip in chips {
            print("Entity: \(chip.entity), Value1: \(chip.tempAttribute1), Value2: \(chip.tempAttribute2)")
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
        print("Current book title: \(book.title ?? "nil")")
        print("Edited title: \(editedTitle)")
        if book.title != editedTitle {
            book.title = editedTitle
        }
        
        book.title = editedTitle
        book.issueNumber = Int16(editedIssueNumber) ?? 0
        
        // Update read percentage
        if book.read != editedReadPercentage {
            book.read = editedReadPercentage
        }
        
        
        // Clear existing BookStoryArcs for the book
        if let existingBookStoryArcs = book.bookStoryArcs as? Set<BookStoryArcs> {
            for bookStoryArc in existingBookStoryArcs {
                viewContext.delete(bookStoryArc)
            }
        }
        
        // For each story arc chip in the chips array
        for chip in chips {
            let attribute1 = chip.tempAttribute1
            let attribute2: Int16?
            switch chip.tempAttribute2 {
            case .string(_):
                attribute2 = nil
            case .int16(let intValue):
                attribute2 = intValue
            }
            
            // Check if a StoryArc with the story arc name already exists globally
            let storyArc: StoryArc
            if let existingStoryArc = allStoryArcs.first(where: { $0.storyArcName?.lowercased() == attribute1.lowercased() }) {
                storyArc = existingStoryArc
            } else {
                // If the StoryArc doesn't exist, create a new one
                storyArc = StoryArc(context: viewContext)
                storyArc.storyArcName = attribute1
            }
            
            // Create a new BookStoryArcs record to associate the book with the story arc
            let bookStoryArc = BookStoryArcs(context: viewContext)
            bookStoryArc.book = book
            bookStoryArc.storyArc = storyArc  // Assign the StoryArc object, not the name
            if let validPartNumber = attribute2 {
                bookStoryArc.storyArcPart = validPartNumber
            } else {
                // Handle the case where partNumber is nil
                bookStoryArc.storyArcPart = 0 // or any default value you want
            }
            
        }
        
        // Clear existing BookEvents for the book
        if let existingBookEvents = book.bookEvents as? Set<BookEvents> {
            for bookEvent in existingBookEvents {
                viewContext.delete(bookEvent)
            }
        }
        
        // For each chip in the eventChips array
        for chip in chips {
            let eventName = chip.tempAttribute1
            let partNumber: Int16?
            switch chip.tempAttribute2 {
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
            
            // Create a new BookEvents record to associate the book with the event
            let bookEvent = BookEvents(context: viewContext)
            bookEvent.books = book
            bookEvent.events = event  // Assign the Event object, not the name
            if let validPartNumber = partNumber {
                bookEvent.eventPart = validPartNumber
            } else {
                // Handle the case where partNumber is nil
                bookEvent.eventPart = 0 // or any default value you want
            }
        }
        
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving edited book: \(error)")
        }
    }
}

struct EditBookView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Book object for preview
        let mockBook = Book(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        mockBook.title = "Sample Book"
        mockBook.issueNumber = 1
        
        return EditBookView(book: mockBook)
    }
}

struct TempChipData: Identifiable {
    var id: UUID = UUID()
    var entity: String
    var tempAttribute1: String
    var tempAttribute2: ValueData
}

extension TempChipData: Equatable {
    static func == (lhs: TempChipData, rhs: TempChipData) -> Bool {
        return lhs.id == rhs.id && lhs.tempAttribute1 == rhs.tempAttribute1 && lhs.tempAttribute2 == rhs.tempAttribute2
    }
}
extension TempChipData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(tempAttribute1)
        hasher.combine(tempAttribute2)
    }
}


//extension saveChanges() {
//    print("Current book title: \(book.title ?? "nil")")
//    print("Edited title: \(editedTitle)")
//    if book.title != editedTitle {
//        book.title = editedTitle
//    }
//    
//    book.title = editedTitle
//    book.issueNumber = Int16(editedIssueNumber) ?? 0
//    
//    // Update read percentage
//    if book.read != editedReadPercentage {
//        book.read = editedReadPercentage
//    }
//    
//    for chip in chips {
//        switch chip.entity {
//        case "BookStoryArcs":
//            processEntity(for: book, value1: chip.value1, value2: chip.value2, allEntities: allStoryArcs, in: viewContext, isStoryArc: true)
//        case "BookEvents":
//            processEntity(for: book, value1: chip.value1, value2: chip.value2, allEntities: allEvents, in: viewContext, isStoryArc: false)
//        default:
//            break
//        }
//    }
//    
//    do {
//        try viewContext.save()
//    } catch {
//        print("Error saving edited book: \(error)")
//    }
//}
