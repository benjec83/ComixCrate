//
//  LibraryView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

import SwiftUI
import Foundation
import CoreData

struct LibraryView: View {
    
    // MARK: - Properties
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: LibraryViewModel
    
    let comicFileHandler = ComicFileHandler()

    
    @FetchRequest(
        entity: Book.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
    ) private var allBooks: FetchedResults<Book>
    var allEntities: AnyFetchedResults
    
    
    @State private var isGalleryView: Bool = true
    @State private var showingDocumentPicker = false
    @State private var selectedBook: Book? = nil
    @State private var isSelecting: Bool = false
    @State private var selectedBooks: Set<Book> = []
    @State private var showingAlert: Bool = false
    @State private var failedFiles = ""

    @State private var activeAlert: ActiveAlert = .deleteSelected
    
    // Progress View properties
    @Binding var isImporting: Bool
    @State private var importProgress: Double = 0.0
    @State private var currentImportingFilename: String = ""
    @EnvironmentObject var importingState: ImportingState
    @State private var importCompleted: Bool = false

    
    
    private let spacing: CGFloat = 10
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    
    enum ActiveAlert { case deleteSelected, deleteAll, importFailed }
    
    private func navigationTitle(for filter: LibraryFilter) -> String {
        switch filter {
        case .allBooks:
            return "Library"
        case .favorites:
            return "Favorites"
        case .currentlyReading:
            return "Currently Reading"
        case .recentlyAdded:
            return "Recently Added"
        }
    }
    
    init(filter: LibraryFilter, isImporting: Binding<Bool>, type: EntityType, allEntities: AnyFetchedResults) {
        viewModel = LibraryViewModel(filter: filter)
        self._isImporting = isImporting
        self.allEntities = allEntities
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            content
        }
        .overlay(
            isImporting ? AnyView(ImportProgressView(progress: $importProgress, currentFilename: $currentImportingFilename, currentBookNumber: $importingState.currentBookNumber, totalBooks: $importingState.totalBooks)) : AnyView(EmptyView())
        )
        
        .toolbar {
            toolbarContent
        }
        .navigationTitle(viewModel.navigationTitle)
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker { urls in
                handleImportedFiles(urls: urls)
            }
        }
        .alert(isPresented: $showingAlert) {
            switch activeAlert {
            case .deleteSelected:
                return deletionAlert(title: "Delete Selected Books", message: "Are you sure you want to delete the selected books?", action: deleteSelectedBooks)
            case .deleteAll:
                return deletionAlert(title: "Delete All Books", message: "Are you sure you want to delete all books?", action: deleteAll)
            case .importFailed:
                return Alert(title: Text("Import Failed"), message: Text("Failed to import the following files: \(failedFiles)"), dismissButton: .default(Text("OK")) {
                    self.showingAlert = false
                    self.importCompleted = false
                })
            }
        }

        .sheet(item: $selectedBook) { item in
            NavigationStack {
                VStack {
                    BookSheetView(book: item, type: .joinEntityEvent, allEntities: allEntities)
                }
            }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var content: some View {
        if viewModel.books.isEmpty {
            emptyLibraryContent
        } else {
            if isGalleryView {
                galleryViewContent
            } else {
                listViewContent
            }
        }
    }
    
    
    private var emptyLibraryContent: some View {
        VStack {
            Text("Please Import Books to Your Library")
                .font(.title)
                .foregroundColor(.secondary)
                .padding()
            
            Button(action: {
                showingDocumentPicker.toggle()
            }) {
                Label("Click Here to Add Books", systemImage: "plus.app")
            }
        }
    }
    
    private var galleryViewContent: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: gridItems, spacing: spacing) {
                ForEach(viewModel.books, id: \.self) { book in
                    bookTile(for: book)
                }
            }
        }
    }
    
    private var listViewContent: some View {
        List(viewModel.books, id: \.self) { book in
            bookRow(for: book)
                .opacity(isSelecting && !selectedBooks.contains(book) ? 0.5 : 1.0)
                .onTapGesture(count: 2) {
                    handleBookSelection(book: book)
                }
                .contextMenu {
                    Button(action: {
                        // Mark the book as read
                    }) {
                        Label("Mark as Read", systemImage: "book.closed")
                    }
                    
                    Button(action: {
                        // Delete the book
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
    }
    
    private func bookTile(for book: Book) -> some View {
        BookTileModel(book: book)
            .opacity(isSelecting && !selectedBooks.contains(book) ? 0.5 : 1.0)
            .onTapGesture(count: 2) {
                handleBookSelection(book: book)
            }
            .contextMenu {
                Button(action: {
                    // Mark the book as read
                }) {
                    Label("Mark as Read", systemImage: "book.closed")
                }
                
                Button(action: {
                    // Delete the book
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
    
    private func bookRow(for book: Book) -> some View {
        Button {
            handleBookSelection(book: book)
        } label: {
            BookRowModel(book: book)
                .opacity(isSelecting && !selectedBooks.contains(book) ? 0.5 : 1.0)
        }
    }
    
    private var toolbarContent: some View {
        HStack {
            if isSelecting {
                deleteButton
                doneButton
            } else {
                //                galleryViewButton
                //                listViewButton
                toggleViewButton
                filterButton
                addBooksButton
                selectButton
                deleteAllButton
            }
        }
    }
    
    private var selectButton: some View {
        Button(action: {
            isSelecting.toggle()
        }) {
            Text("Select")
        }
    }
    
    private var deleteAllButton: some View {
        Button(action: {
            activeAlert = .deleteAll
            showingAlert = true
        }) {
            Text("Delete All")
                .foregroundColor(.red)
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            activeAlert = .deleteSelected
            showingAlert = true
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
    
    private var doneButton: some View {
        Button(action: {
            isSelecting.toggle()
            selectedBooks.removeAll()
        }) {
            Text("Done")
        }
    }
    
    private var toggleViewButton: some View {
        Button(action: {
            isGalleryView.toggle()
        }) {
            if isGalleryView {
                Label("List", systemImage: "line.3.horizontal")
            } else {
                Label("Gallery", systemImage: "square.grid.2x2")
            }
        }
    }
    
    private var filterButton: some View {
        Button(action: {
            // TODO: Implement filter action
        }) {
            Label("Filter", systemImage: "line.3.horizontal.decrease")
        }
    }
    
    private var addBooksButton: some View {
        Button(action: {
            showingDocumentPicker.toggle()
        }) {
            Label("Add Books", systemImage: "plus.app")
        }
    }
    
    // MARK: - Helper Functions
    
    private func handleImportedFiles(urls: [URL]) {
        importingState.isImporting = true
        let totalFiles = Double(urls.count)
        var failedImports: [String] = []

        DispatchQueue.global(qos: .userInitiated).async {
            for (index, url) in urls.enumerated() {
                let filename = url.lastPathComponent
                    
                
            do {
                try comicFileHandler.handleImportedFile(at: url, in: self.viewContext)
            } catch {
                print("Error handling imported file: \(error)")
                failedImports.append(filename)
                continue
            }
                    
                let currentProgress = Double(index + 1) / totalFiles
                    
                DispatchQueue.main.async {
                    importingState.importProgress = currentProgress
                    importingState.currentImportingFilename = filename
                    importingState.currentBookNumber = index + 1
                    importingState.totalBooks = urls.count
                }
            }
                
            DispatchQueue.main.async {
                importingState.isImporting = false
                importCompleted = true
                print("importCompleted = \(importCompleted)")
                if !failedImports.isEmpty {
                    self.failedFiles = failedImports.joined(separator: ", ")
                    print("Failed Filed: \(failedFiles)")
                    self.activeAlert = .importFailed
                    print("Active Alert = \(activeAlert)")
                    print("Before setting showingAlert")
                    self.showingAlert = true
                    print("After setting showingAlert")
                    print("showingAlert = \(showingAlert)")
                }
            }

        }
    }

    private func handleBookSelection(book: Book) {
        if isSelecting {
            toggleSelection(for: book)
        } else {
            selectedBook = book
        }
    }
    
    private func deletionAlert(title: String, message: String, action: @escaping () -> Void) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .default(Text("Cancel")),
            secondaryButton: .destructive(Text("Delete"), action: action)
        )
    }
    
    private func toggleSelection(for book: Book) {
        if selectedBooks.contains(book) {
            selectedBooks.remove(book)
        } else {
            selectedBooks.insert(book)
        }
    }
    
    // MARK: - CRUD Operations
    
    func deleteSelectedBooks() {
        for book in selectedBooks {
//            deleteRelatedEntitiesIfOrphaned(book: book, in: viewContext)
            viewContext.delete(book)
        }
        CoreDataHelper.shared.saveContext(context: viewContext)
        selectedBooks.removeAll()
        isSelecting = false
    }
    
    func deleteAll() {
        for book in viewModel.books {
//            deleteRelatedEntitiesIfOrphaned(book: book, in: viewContext)
            viewContext.delete(book)
        }
        CoreDataHelper.shared.saveContext(context: viewContext)
    }
    
//    func deleteRelatedEntitiesIfOrphaned(book: Book, in context: NSManagedObjectContext) {
//        // Check Series
//        if let series = book.bookSeries {
//            checkAndDeleteEntity(entity: series, relatedTo: book, byKey: "bookSeries", in: context)
//        }
//        if let storyArcs = book.arcJoins as? Set<StoryArc> {
//            for storyArc in storyArcs {
//                checkAndDeleteEntity(entity: storyArc, relatedTo: book, byKey: "storyArc", in: context)
//            }
//        }
//        if let events = book.eventJoins as? Set<Event> {
//            for event in events {
//                checkAndDeleteEntity(entity: event, relatedTo: book, byKey: "event", in: context)
//            }
//        }
//        if let publisher = book.publisher {
//            checkAndDeleteEntity(entity: publisher, relatedTo: book, byKey: "publisher", in: context)
//        }
//        // Add similar checks for other relationships like Publisher, Author, etc.
//        // Example:
//        // if let publisher = book.publisher {
//        //     checkAndDeleteEntity(entity: publisher, relatedTo: book, byKey: "publisher", in: context)
//        // }
//    }
    
    func checkAndDeleteEntity<T: NSManagedObject>(entity: T, relatedTo book: Book, byKey key: String, in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", entity)
        
        do {
            let relatedBooks = try context.fetch(fetchRequest)
            if relatedBooks.count == 1 {
                context.delete(entity)
            }
        } catch {
            print("Error fetching related books for \(key): \(error)")
        }
    }
    
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context:", error.localizedDescription)
        }
    }
}
