////
////  OldCode.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/6/23.
////
//
//import SwiftUI
//
////
////  ChipUtilities.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/4/23.
////
//
//import SwiftUI
//import CoreData
//
//enum ChipType: String {
//    case storyArc = "BookStoryArcs"
//    case creator
//    // Add other types as needed
//
//    func iconName() -> String {
//        switch self {
//        case .storyArc:
//            return "sparkles.rectangle.stack.fill"
//        case .creator:
//            return "person.circle.fill"
//        }
//    }
//}
//
//struct Chip: View {
//    var label: String
//    var onDelete: (() -> Void)? = nil
//    var type: ChipType
//    var showIcon: Bool = true
//    var showDeleteButton: Bool = true
//    var maxWidth: CGFloat = 100  // Default value, you can adjust this or set it when creating the Chip
//    
//    var body: some View {
//        HStack {
//            if showIcon {
//                Image(systemName: iconName())
//                    .foregroundColor(.white)
//            }
//            Text(label)
//                .lineLimit(1)
//                .truncationMode(.tail)
//            if showDeleteButton, let onDelete = onDelete {
//                Button(action: onDelete) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.white)
//                }
//                .buttonStyle(PlainButtonStyle())
//            }
//        }
//        .padding(.horizontal, label.count < 10 ? 10 : 14)  // Conditional padding
//        .padding(.vertical, 5)
//        .background(Color.accentColor)
//        .foregroundColor(.white)
//        .cornerRadius(20)
//    }
//    
//    func iconName() -> String {
//        return type.iconName()
//    }
//}
//
//
//struct ChipView: View {
//    @Binding var chips: [TempChipData]
//    
//    @Binding var editedStoryArcName: String
//    @Binding var editedStoryArcPart: String
//    
//    @Binding var chipViewHeight: CGFloat
//    
//    var fontSize: CGFloat = 16
//    
//    let estimatedRowHeight: CGFloat = 40  // This is an estimate based on your chip design
//    
//    
//
//    
//    // Adding Geometry Effect to Chip...
//    @Namespace var animation
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let containerWidth = geometry.size.width
//            
//            VStack(alignment: .leading, spacing: 10) {
//                ForEach(getRows(containerWidth: containerWidth), id: \.self) { rows in
//                    HStack(spacing: 1) {
//                        ForEach(rows) { row in
//                            RowView(chip: row)
//                        }
//                    }
//                }
//            }
//            .padding(.bottom, 20)
//            .fixedSize(horizontal: false, vertical: true)
//            .animation(.easeInOut, value: chips)
//            .background(GeometryReader { gp -> Color in
//                DispatchQueue.main.async {
//                    // Update on next cycle with calculated height of VStack
//                    self.chipViewHeight = gp.size.height
//                }
//                return Color.clear
//            })
//        }
//    }
//    
//    func createLabel(for chip: TempChipData) -> String {
//        switch chip.value2 {
//        case .string:
//            return chip.value1
//        case .int16(let intValue):
//            return (intValue != 0) ? "\(chip.value1) - Part \(intValue)" : chip.value1
//        }
//    }
//
//    @ViewBuilder
//    func RowView(chip: TempChipData) -> some View {
//        let label = createLabel(for: chip)
//
//        Chip(label: label, onDelete: {
//            if let index = chips.firstIndex(where: {
//                $0.value1 == chip.value1 &&
//                (String(describing: $0.value2) == String(describing: chip.value2))
//            }) {
//                chips.remove(at: index)
//            }
//        }, type: .storyArc, showIcon: true, showDeleteButton: true)
//        .font(.system(size: fontSize))
//        .padding(.horizontal, 5)
//        .lineLimit(1)
//        .frame(maxWidth: 300)
//        .matchedGeometryEffect(id: chip.id, in: animation)
//        .onTapGesture {
//            if let index = chips.firstIndex(where: {
//                $0.value1 == chip.value1 &&
//                (String(describing: $0.value2) == String(describing: chip.value2))
//            }) {
//                editedStoryArcName = chip.value1
//                switch chip.value2 {
//                case .string(let stringValue):
//                    editedStoryArcPart = stringValue
//                case .int16(let intValue):
//                    editedStoryArcPart = "\(intValue)"
//                }
//                chips.remove(at: index) // Remove the old chip
//            }
//        }
//    }
//
//    
//    func getRows(containerWidth: CGFloat) -> [[TempChipData]] {
//        var rows: [[TempChipData]] = []
//        var currentRow: [TempChipData] = []
//        
//        var totalWidth: CGFloat = 0
//        
//        chips.forEach { chip in
//            let label: String
//            switch chip.value2 {
//            case .string(_):
//                label = chip.value1
//            case .int16(let intValue):
//                label = intValue != 0 ? "\(chip.value1) - Part \(intValue)" : chip.value1
//            }
//            let font = UIFont.systemFont(ofSize: fontSize)
//            let attributes = [NSAttributedString.Key.font: font]
//            let size = (label as NSString).size(withAttributes: attributes)
//            
//            // updating total width...
//            totalWidth += (size.width + 40)
//            
//            // checking if total width is greater than size...
//            if totalWidth > containerWidth {
//                rows.append(currentRow)
//                currentRow.removeAll()
//                currentRow.append(chip)
//                totalWidth = size.width + 40  // Reset total width for the new row
//            } else {
//                currentRow.append(chip)
//            }
//        }
//        
//        // Safe check...
//        if !currentRow.isEmpty {
//            rows.append(currentRow)
//        }
//        return rows
//    }
//}
//
////
////  EditBookView.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/4/23.
////
//
//import SwiftUI
//
////
////  EditBookView.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/3/23.
////
//
//import SwiftUI
//import CoreData
//
//struct EditBookView: View {
//
//    @Binding var book: Book
//    @State private var editedTitle: String
//    @State private var editedIssueNumber: String
//    @State private var editedStoryArcName: String
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.presentationMode) var presentationMode
//
//
//    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
//    private var allStoryArcs: FetchedResults<StoryArc>
//    
//    
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
////         Populate the chips array with existing story arcs from the book
//        let existingStoryArcs: [TempChipData] = (book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap {
//            let entityType = String(describing: type(of: $0).self) // This will give "BookStoryArcs"
//            return TempChipData(entity: entityType, value1: $0.storyArc?.storyArcName ?? "", value2: ValueData.int16($0.storyArcPart))
//        } ?? []
//
//        _chips = State(initialValue: existingStoryArcs)
//        print("Existing story arcs: \(existingStoryArcs)")
//
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
//                    saveChanges()
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
//
//}
//
//extension EditBookView {
//    
//    
//    func filterStoryArcs() -> [StoryArc] {
//        let query = editedStoryArcName.lowercased()
//        return allStoryArcs.filter { ($0.storyArcName?.lowercased().contains(query) ?? false) }
//    }
//    
//    func saveChanges() {
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
//
//struct EditBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock Book object for preview
//        let mockBook = Book(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
//        mockBook.title = "Sample Book"
//        mockBook.issueNumber = 1
//        
//        return EditBookView(book: mockBook)
//    }
//}
//
//struct TempChipData: Identifiable {
//    var id: UUID = UUID()
//    var entity: String
//    var value1: String
//    var value2: ValueData
//}
//
//extension TempChipData: Equatable {
//    static func == (lhs: TempChipData, rhs: TempChipData) -> Bool {
//        return lhs.id == rhs.id && lhs.value1 == rhs.value1 && lhs.value2 == rhs.value2
//    }
//}
//extension TempChipData: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//        hasher.combine(value1)
//        hasher.combine(value2)
//    }
//}
//
//
////
////  SpecializedTextBoxes.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/4/23.
////
//
//import SwiftUI
//import CoreData
//
//protocol EntityProtocol: NSManagedObject { }
//
//extension StoryArc: EntityProtocol { }
//// Add other entities as needed
//
//struct AnyFetchedResults {
//    private let _objects: () -> [EntityProtocol]
//    
//    init<T: EntityProtocol>(_ results: FetchedResults<T>) {
//        _objects = { results.map { $0 } }
//    }
//    
//    var objects: [EntityProtocol] {
//        _objects()
//    }
//}
//struct EntityTextFieldView: View {
//    var entityType: TextFieldEntities
//    @Binding var chips: [TempChipData]
//    var allEntities: AnyFetchedResults
//    var placeholder: String = "Enter item..."
//
//    @FocusState private var isTextFieldFocused: Bool
//    @State private var showAllSuggestionsSheet: Bool = false
//
//    // Computed property to get filtered entities based on the current input
//    var filteredEntities: [NSManagedObject] {
//        let lowercasedInput = entityType.bindings.0.wrappedValue.lowercased()
//        // This filtering logic might need to be updated based on the actual attribute you're filtering on
//        return allEntities.objects.filter { ($0.value(forKey: entityType.attributes.field1.attribute) as? String)?.lowercased().contains(lowercasedInput) == true }
//            .prefix(5)  // Take only the first 5 results
//            .map { $0 }
//    }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                // TextField for the first attribute (e.g., storyArcName, bookCreatorName, etc.)
//                TextField(entityType.attributes.field1.displayName, text: entityType.bindings.0, onCommit: {
//                    if let firstSuggestion = filteredEntities.first {
//                        entityType.bindings.0.wrappedValue = firstSuggestion.value(forKey: entityType.attributes.field1.attribute) as? String ?? ""
//                    }
//                })
//                .textFieldStyle(PlainTextFieldStyle())
//                .multilineTextAlignment(.leading)
//                .focused($isTextFieldFocused)
//                
//                // TextField for the second attribute (e.g., storyArcPart, bookCreatorRole, etc.)
//                TextField(entityType.attributes.field2.displayName, text: entityType.bindings.1)
//                    .textFieldStyle(PlainTextFieldStyle())
//                    .multilineTextAlignment(.leading)
//                    .keyboardType(entityType.keyboardTypeForField2)  // Use the computed property here
//
//                // "+" Button to add the new entity
//                Button(action: {
//                    // Check if the first attribute is not empty
//                    guard !entityType.bindings.0.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//                        return
//                    }
//                    
//                    let valueData: ValueData
//                    switch entityType.fieldTypes.1 {
//                    case .string:
//                        valueData = .string(entityType.bindings.1.wrappedValue)
//                    case .int16:
//                        if let intValue = Int16(entityType.bindings.1.wrappedValue) {
//                            valueData = .int16(intValue)
//                        } else {
//                            valueData = .int16(0) // or any default value you want
//                        }
//                    }
//
//                    let newEntity = TempChipData(entity: entityType.attributes.field1.attribute, value1: entityType.bindings.0.wrappedValue, value2: valueData)
//                    if !chips.contains(where: {
//                        $0.value1 == newEntity.value1 && $0.value2 == newEntity.value2
//                    }) {
//                        chips.append(newEntity)
//                    }
//                    entityType.bindings.0.wrappedValue = ""
//                    entityType.bindings.1.wrappedValue = ""
//                    print("Adding new chip: \(newEntity)")
//                    
//                }) {
//                    Image(systemName: "plus.circle.fill")
//                        .foregroundColor(.accentColor)
//                }
//                .buttonStyle(PlainButtonStyle())
//                .frame(width: 30, height: 30) // Limit the button size
//            }
//            // Displaying filtered results
//            VStack(alignment: .leading) {
//                // Displaying filtered results
//                if isTextFieldFocused && !filteredEntities.isEmpty {
//                    ForEach(filteredEntities.indices, id: \.self) { index in
//                        let entity = filteredEntities[index]
//                        Text(entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? "")  // Use the unwrapped attribute value
//                            .padding(.vertical, 5)
//                            .onTapGesture {
//                                entityType.bindings.0.wrappedValue = entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? ""
//                                isTextFieldFocused = false
//                            }
//                    }
//                    .foregroundColor(.accentColor)
//                }
//                
//                Button("See All") {
//                    showAllSuggestionsSheet.toggle()
//                }
//                .buttonStyle(PlainButtonStyle())
//                .foregroundColor(.accentColor)
//                .padding(.top, 10)
//            }
//            .sheet(isPresented: $showAllSuggestionsSheet) {  // Attach the .sheet modifier here
//                List {
//                    ForEach(allEntities.objects, id: \.objectID) { entity in
//                        Button(action: {
//                            // Update the text fields
//                            entityType.bindings.0.wrappedValue = entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? ""
//                            // Dismiss the sheet
//                            showAllSuggestionsSheet = false
//                        }) {
//                            Text(entity.value(forKey: entityType.attributes.field1.attribute) as? String ?? "")
//                        }
//                    }
//                }
//            }
//
//        }
//    }
//
//}
//
//enum ValueData: Hashable {
//    case string(String)
//    case int16(Int16)
//}
//
//extension ValueData: Equatable {
//    static func == (lhs: ValueData, rhs: ValueData) -> Bool {
//        switch (lhs, rhs) {
//        case (.string(let lhsString), .string(let rhsString)):
//            return lhsString == rhsString
//        case (.int16(let lhsInt), .int16(let rhsInt)):
//            return lhsInt == rhsInt
//        default:
//            return false
//        }
//    }
//}
//
//enum FieldType {
//    case string
//    case int16
//}
//
//
//enum TextFieldEntities {
//    case bookStoryArc(Binding<String>, Binding<String>, FieldType, FieldType)
//    case bookCreatorRole(Binding<String>, Binding<String>, FieldType, FieldType)
//    case bookEvent(Binding<String>, Binding<String>, FieldType, FieldType)
//    
//    var attributes: (field1: (attribute: String, displayName: String), field2: (attribute: String, displayName: String)) {
//        switch self {
//        case .bookStoryArc:
//            return (field1: ("storyArcName", "Add Story Arc"), field2: ("storyArcPart", "Add Story Arc Part"))
//        case .bookCreatorRole:
//            return (field1: ("bookCreatorName", "Creator Name"), field2: ("bookCreatorRole", "Role"))
//        case .bookEvent:
//            return (field1: ("bookEventName", "Event Name"), field2: ("bookEventPart", "Part"))
//        }
//    }
//    
//    var bindings: (Binding<String>, Binding<String>) {
//        switch self {
//        case .bookStoryArc(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        case .bookCreatorRole(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        case .bookEvent(let binding1, let binding2, _, _):
//            return (binding1, binding2)
//        }
//    }
//    
//    var fieldTypes: (FieldType, FieldType) {
//        switch self {
//        case .bookStoryArc(_, _, let type1, let type2):
//            return (type1, type2)
//        case .bookCreatorRole(_, _, let type1, let type2):
//            return (type1, type2)
//        case .bookEvent(_, _, let type1, let type2):
//            return (type1, type2)
//        }
//    }
//    var keyboardTypeForField2: UIKeyboardType {
//        switch fieldTypes.1 {
//        case .string:
//            return .default
//        case .int16:
//            return .numberPad
//        }
//    }
//}
//
//
//
