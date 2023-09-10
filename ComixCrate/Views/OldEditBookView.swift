////
////  OldEditBookView.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/6/23.
////
//
//import SwiftUI
//import CoreData
//
//struct OldEditBookView: View {
//    
//    @Binding var book: Book
//    
//    @State private var editedTitle: String
//    @State private var editedIssueNumber: String
//    @State private var editedStoryArcName: String
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.presentationMode) var presentationMode
//    
//    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
//    private var allStoryArcs: FetchedResults<StoryArc>
//    
//    @State private var showAlert: Bool = false
//    
//    @State private var chips: [TempChipData] = []
//    private var bookStoryArcNames: [String] {
//        (book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap { $0.storyArc?.storyArcName  } ?? []
//    }
//    @State private var editedStoryArcPart: String = ""
//    
//    @State private var chipViewHeight: CGFloat = 10  // Initial value, can be adjusted
//    
//    var onDelete: (() -> Void)? = nil
//    
//    //Bindings for EntityTextFieldView
//    @State private var attribute1: String = ""
//    @State private var attribute2: String = ""
//    
//    init(book: Book) {
//        _book = .constant(book)
//        _editedTitle = State(initialValue: book.title ?? "")
//        _editedIssueNumber = State(initialValue: "\(book.issueNumber)")
//        let firstStoryArcName = (book.bookStoryArcs as? Set<StoryArc>)?.first?.storyArcName ?? ""
//        _editedStoryArcName = State(initialValue: firstStoryArcName)
//        
//        //         Populate the chips array with existing story arcs from the book
//        let existingStoryArcs: [TempChipData] = (book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap {
//            let entityType = String(describing: type(of: $0).self) // This will give "BookStoryArcs"
//            return TempChipData(entity: entityType, tempValue1: $0.storyArc?.storyArcName ?? "", tempValue2: ValueData.int16($0.storyArcPart))
//        } ?? []
//        
//        _chips = State(initialValue: existingStoryArcs)
//        print("Existing story arcs: \(existingStoryArcs)")
//    }
//    
//    var body: some View {
//        VStack {
//            Form {
//                TextField("Title", text: $editedTitle)
//                TextField("Issue Number", text: $editedIssueNumber)
//                
//                Section(header: Text("Story Arcs")) {
//                    ChipView(chips: $chips, editedStoryArcName: $editedStoryArcName, editedStoryArcPart: $editedStoryArcPart, chipViewHeight: $chipViewHeight)
//                        .padding(.vertical, 15)
//                        .frame(height: chipViewHeight)
//                    
//                    EntityTextFieldView(entityType: .bookStoryArc($editedStoryArcName, $editedStoryArcPart, .string, .int16), chips: $chips, allEntities: AnyFetchedResults(allStoryArcs))
//                    
//                }
//            }
//            
//            Spacer()
//            
//            HStack {
//                Spacer()
//                Button("Save") {
//                    saveChangesOld()
//                    presentationMode.wrappedValue.dismiss()
//                }
//                Button("Cancel") {
//                    showAlert = true
//                }
//                .alert(isPresented: $showAlert) {
//                    Alert(title: Text("Are you sure?"),
//                          message: Text("Any changes will not be saved."),
//                          primaryButton: .destructive(Text("Don't Save")) {
//                        presentationMode.wrappedValue.dismiss()
//                    },
//                          secondaryButton: .cancel())
//                }
//                .foregroundColor(.gray)
//                
//                Spacer()
//            }
//            .padding()
//        }
//    }
//}
//
//
//
//
////
//extension EditBookView {
//    
//    
////    func filterStoryArcs() -> [StoryArc] {
////        let query = editedStoryArcName.lowercased()
////        return allStoryArcs.filter { ($0.storyArcName?.lowercased().contains(query) ?? false) }
////    }
//    
//    func saveChangesOld() {
//        print("Current book title: \(book.title ?? "nil")")
//        print("Edited title: \(editedTitle)")
//        if book.title != editedTitle {
//            book.title = editedTitle
//        }
//        
//        book.title = editedTitle
//        book.issueNumber = Int16(editedIssueNumber) ?? 0
//        
//        
//        // Clear existing BookStoryArcs for the book
//        if let existingBookStoryArcs = book.bookStoryArcs as? Set<BookStoryArcs> {
//            for bookStoryArc in existingBookStoryArcs {
//                viewContext.delete(bookStoryArc)
//            }
//        }
//        
//        // For each chip in the chips array
//        for chip in chips {
//            let storyArcName = chip.value1
//            let partNumber: Int16?
//            switch chip.value2 {
//            case .string(_):
//                partNumber = nil
//            case .int16(let intValue):
//                partNumber = intValue
//            }
//            
//            // Check if a StoryArc with the story arc name already exists globally
//            let storyArc: StoryArc
//            if let existingStoryArc = allStoryArcs.first(where: { $0.storyArcName?.lowercased() == storyArcName.lowercased() }) {
//                storyArc = existingStoryArc
//            } else {
//                // If the StoryArc doesn't exist, create a new one
//                storyArc = StoryArc(context: viewContext)
//                storyArc.storyArcName = storyArcName
//            }
//            
//            // Create a new BookStoryArcs record to associate the book with the story arc
//            let bookStoryArc = BookStoryArcs(context: viewContext)
//            bookStoryArc.book = book
//            bookStoryArc.storyArc = storyArc  // Assign the StoryArc object, not the name
//            if let validPartNumber = partNumber {
//                bookStoryArc.storyArcPart = validPartNumber
//            } else {
//                // Handle the case where partNumber is nil
//                bookStoryArc.storyArcPart = 0 // or any default value you want
//            }
//            
//        }
//        
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error saving edited book: \(error)")
//        }
//    }
//}
////
////struct EditBookView_Previews: PreviewProvider {
////    static var previews: some View {
////        // Mock Book object for preview
////        let mockBook = Book(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
////        mockBook.title = "Sample Book"
////        mockBook.issueNumber = 1
////
////        return EditBookView(book: mockBook)
////    }
////}
////
////struct TempChipData: Identifiable {
////    var id: UUID = UUID()
////    var entity: String
////    var value1: String
////    var value2: ValueData
////}
////
////extension TempChipData: Equatable {
////    static func == (lhs: TempChipData, rhs: TempChipData) -> Bool {
////        return lhs.id == rhs.id && lhs.value1 == rhs.value1 && lhs.value2 == rhs.value2
////    }
////}
////extension TempChipData: Hashable {
////    func hash(into hasher: inout Hasher) {
////        hasher.combine(id)
////        hasher.combine(value1)
////        hasher.combine(value2)
////    }
////}
////
////
