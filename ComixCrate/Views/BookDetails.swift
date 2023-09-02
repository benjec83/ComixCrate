//
//  BookDetails.swift
//  Comic Reader
//
//  Created by Benjamin Carney on 1/14/23.
//

import SwiftUI
import CoreData

// MARK: - BookMainDetails

struct BookMainDetails: View {
    @ObservedObject var book: Book
    
    private var seriesName: String? {
        book.series?.name
    }
    
    private var storyArcNames: [String] {
        (book.storyArc as? Set<StoryArc>)?.compactMap { $0.storyArcName } ?? []
    }
    

    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("#\(String(book.issueNumber)) - \(book.title ?? "")")
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("\(seriesName ?? "") (\(String(book.volumeYear)))")
                    .font(.caption2)
                    .lineLimit(2)
                
                Text("Story Arcs: \((book.storyArc as? Set<StoryArc>)?.compactMap { $0.storyArcName }.joined(separator: ", ") ?? "Unknown")")
                    .font(.caption2)
                    .fontWeight(.light)
                    .lineLimit(1)
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: 360)
    }
}

// MARK: - BookSecondaryDetails

struct BookSecondaryDetails: View {
    var book: Book
    
    var body: some View {
        HStack(alignment: .top) {
            detailSection(title: "Publisher", image: AnyView(FakePublisherLogo()))
            Divider()
            detailSection(title: "Released", mainText: book.releaseDate?.yearString, subText: book.releaseDate?.formattedString)
            Divider()
            detailSection(title: "Length", mainText: "\(book.pageCount)", subText: "Pages")
        }
        .padding(.top)
        .frame(height: 65)
    }
    
    private func detailSection(title: String, image: AnyView? = nil, mainText: String? = nil, subText: String? = nil) -> some View {
        VStack {
            Text(title)
                .font(.subheadline)
            Spacer().frame(height: 1)
            if let imageView = image {
                imageView
                    .scaledToFit()
                    .frame(height: 40)
            } else {
                Text(mainText ?? "")
                Spacer().frame(height: 1)
                Text(subText ?? "")
                    .font(.caption)
            }
            Spacer()
        }
        .frame(width: 120)
    }
}

// MARK: - BookActionButtons

struct BookActionButtons: View {
    @ObservedObject var book: Book
    @State private var userRating: Double
    @Environment(\.managedObjectContext) private var viewContext
    
    enum ActionTitle: String {
        case readNow = "Read Now"
        case markAsRead = "Mark As Read"
        case markAsUnread = "Mark As Unread"
        case addToReadingPile = "Add to Reading Pile"
    }
    
    init(book: Book) {
        self.book = book
        _userRating = State(initialValue: Double(book.personalRating) / 2.0)
    }
    
    var body: some View {
        VStack {
            Spacer()
            actionButton(title: .readNow, icon: "magazine")
            actionButton(title: bookIsRead ? .markAsUnread : .markAsRead, icon: "checkmark.circle")
            actionButton(title: .addToReadingPile, icon: "square.stack.3d.up")
            Spacer()
            ratingsSection(title: "Personal Rating", rating: userRating)
        }
        .frame(height: 250)
        .onAppear {
            userRating = book.personalRating
        }
    }
    
    private var bookIsRead: Bool {
        book.read == 1
    }
    
    private func actionButton(title: ActionTitle, icon: String) -> some View {
        Button {
            switch title {
            case .markAsRead:
                markBookAsRead()
            case .markAsUnread:
                markBookAsUnread()
            default:
                print("\(title.rawValue) \(book.title ?? "") pressed")
            }
        } label: {
            Label(title.rawValue, systemImage: icon)
                .frame(width: 345.0, height: 55.0)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(51.0)
                .font(.headline)
        }
    }
    
    private func markBookAsRead() {
        book.read = 1
        saveContext()
    }
    
    private func markBookAsUnread() {
        book.read = 0
        saveContext()
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to update read status: \(error)")
        }
    }
    
    private func ratingsSection(title: String, rating: Double) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            HStack(spacing: -1.0) {
                ForEach(0..<5) { index in
                    starImage(for: index, in: rating)
                        .onTapGesture {
                            updateUserRating(to: Double(index) + 0.5)
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let width = value.location.x
                                    let computedRating = Double(width / 30)
                                    updateUserRating(to: min(max(computedRating, 0.5), 5))
                                }
                        )
                }
            }
        }
    }
    
    private func starImage(for index: Int, in rating: Double) -> some View {
        if rating > Double(index) + 0.5 {
            return Image(systemName: "star.fill").foregroundColor(Color.yellow)
        } else if rating > Double(index) {
            return Image(systemName: "star.leadinghalf.fill").foregroundColor(Color.yellow)
        } else {
            return Image(systemName: "star").foregroundColor(Color.gray)
        }
    }
    
    private func updateUserRating(to newRating: Double) {
        userRating = newRating
        book.personalRating = newRating
        saveContext()
    }
}

// MARK: - BookDetailTabs

struct BookDetailTabs: View {
    @State private var isFavorite: Bool
    @State private var isEditing: Bool = false
    
    @ObservedObject var book: Book
    
    
    
    public init(book: Book) {
        self.book = book
        _isFavorite = State(initialValue: book.isFavorite)
    }
    
    private var seriesName: String? {
        book.series?.name
    }
    
    var body: some View {
        TabView {
            BookDetailsMainView(book: book)
                .tabItem {
                    Image(systemName: "info")
                    Text("Information")
                }
            BookDetailsCreativesView(book: book)
                .tabItem {
                    Image(systemName: "photo.artframe")
                    Text("Creative Team")
                }
            BookDetailsDetailsView(book: book)
                .tabItem {
                    Image(systemName: "star")
                    Text("Details")
                }
            BookDetailsLibraryView(book: book)
                .tabItem {
                    Image(systemName: "rectangle.grid.3x2")
                    Text("Collection")
                }
        }
        .navigationTitle("#" + "\(String(book.issueNumber))" + " - " + "\(book.title ?? seriesName ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                HStack {
            Button {
                isEditing = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .sheet(isPresented: $isEditing) {
                EditBookView(book: book)
            }
            FavoriteButton(book: book, context: book.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            
            Menu {
                Button(action: {}) {
                    Label("Button 1", systemImage: "pencil")
                }
                Button(action: {}) {
                    Label("Button 2", systemImage: "pencil")
                }
                Divider()
                Button(action: {}) {
                    Label("Button 3", systemImage: "pencil")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
        }
        )
    }
}

// MARK: - BookDetails Views

struct BookDetailsMainView: View {
    @ObservedObject var book: Book
    @State private var shouldCacheHighQualityThumbnail: Bool = false
    
    public init(book: Book) {
        self.book = book
    }
    
    public var body: some View {
        
        ScrollView {
            HStack {
                HStack(alignment: .center) {
                    ThumbnailProvider(book: book, isHighQuality: true)
                        .scaledToFit()
                        .frame(height: 390.0)
                        .frame(maxWidth: 255)
                        .padding(.all)
                        .shadow(radius: 1)
                }
                VStack {
                    BookMainDetails(book: book)
                    BookSecondaryDetails(book: book)
                    BookActionButtons(book: book)
                }
                .padding(.all)
                .frame(width: 380)
            }
            .frame(width: 710)
            
            Divider()
                .padding(.horizontal, 30.0)
            VStack(alignment: .leading) {
                HStack {
                    Text("Description:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5.0)
                    Spacer()
                }
                Text(book.sypnosis ?? "")
            }
            .font(.subheadline)
            .padding(.horizontal)
            .frame(maxWidth: 690)
            
        }
        .onAppear {
            shouldCacheHighQualityThumbnail = true
        }
        
        ThumbnailProvider(book: book, isHighQuality: true, shouldCacheHighQuality: $shouldCacheHighQualityThumbnail)
    }
}

struct BookDetailsLibraryView: View {
    @ObservedObject var book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Library View")
        }
    }
}

struct BookDetailsDetailsView: View {
    @ObservedObject var book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Details View")
        }
    }
}

struct BookDetailsCreativesView: View {
    @ObservedObject var book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Creatives View")
        }
    }
}

struct FakePublisherLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
            
            Text("P")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

struct EditBookView: View {
    @Binding var book: Book
    @State private var editedTitle: String
    @State private var editedIssueNumber: String
    @State private var editedStoryArcName: String
    
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    
    @State private var isShowingSuggestions: Bool = false
    @State private var showAllSuggestionsSheet: Bool = false
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert: Bool = false
    
    @State private var chips: [String] = []
    private var storyArcNames: [String] {
        (book.storyArc as? Set<StoryArc>)?.compactMap { $0.storyArcName } ?? []
    }

    
    init(book: Book) {
        _book = .constant(book)
        _editedTitle = State(initialValue: book.title ?? "")
        _editedIssueNumber = State(initialValue: "\(book.issueNumber)")
        _editedStoryArcName = State(initialValue: (book.storyArc as? Set<StoryArc>)?.first?.storyArcName ?? "")
        _chips = State(initialValue: (book.storyArc as? Set<StoryArc>)?.compactMap { $0.storyArcName } ?? [])
    }
    
    var body: some View {
        VStack {
            Form {
                TextField("Title", text: $editedTitle)
                TextField("Issue Number", text: $editedIssueNumber)
                VStack {
                    TextField("Story Arc", text: $editedStoryArcName, onEditingChanged: { isEditing in
                        self.isShowingSuggestions = isEditing
                    })
                    ChipsView(chips: chips)
                    .gesture(
                        TapGesture()
                            .onEnded {
                                UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                            }
                    )
                    
                    if isShowingSuggestions {
                        List(filterStoryArcs().prefix(3), id: \.self) { storyArc in
                            Button(action: {
                                self.editedStoryArcName = storyArc.storyArcName ?? ""
                                self.isShowingSuggestions = false
                            }) {
                                Text(storyArc.storyArcName ?? "")
                                    .font(.subheadline) // Adjust the font size if needed
                            }
                            .padding(.vertical, 6) // Adjust vertical padding
                        }
                        .frame(height: 15) // Adjust the total height of the List
                        Spacer(minLength: 50)
                        Button("See All") {
                            showAllSuggestionsSheet = true
                        }
                        
                    }
                    
                }
                .sheet(isPresented: $showAllSuggestionsSheet) {
                    List(filterStoryArcs(), id: \.self) { storyArc in
                        Button(action: {
                            self.editedStoryArcName = storyArc.storyArcName ?? ""
                            self.showAllSuggestionsSheet = false
                        }) {
                            Text(storyArc.storyArcName ?? "")
                        }
                    }
                }
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
    
    func filterStoryArcs() -> [StoryArc] {
        let query = editedStoryArcName.lowercased()
        return allStoryArcs.filter { ($0.storyArcName?.lowercased().contains(query) ?? false) }
    }
    
    func saveChanges() {
        book.title = editedTitle
        book.issueNumber = Int16(editedIssueNumber) ?? 0
        
        // Check if a StoryArc with the edited name already exists in the book's storyArc relationship
        if let existingStoryArc = (book.storyArc as? Set<StoryArc>)?.first(where: { $0.storyArcName?.lowercased() == editedStoryArcName.lowercased() }) {
            // ... (You can add further logic here if needed)
        } else {
            // If the StoryArc doesn't exist, create a new one
            let newStoryArc = StoryArc(context: viewContext)
            newStoryArc.storyArcName = editedStoryArcName
            
            // Add the new StoryArc to the book's storyArc relationship
            if let existingSet = book.storyArc as? NSMutableSet {
                existingSet.add(newStoryArc)
            } else {
                book.storyArc = NSMutableSet(object: newStoryArc)
            }
            
            chips.append(editedStoryArcName)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving edited book: \(error)")
        }
    }

}
    
    
    
    
    
    
