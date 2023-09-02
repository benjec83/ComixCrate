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
    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)])
    private var allBooks: FetchedResults<Book>
    
    @State private var isGalleryView: Bool = true
    @State private var showingDocumentPicker = false
    @State private var selectedBook: Book? = nil
    @State private var isSelecting: Bool = false
    @State private var selectedBooks: Set<Book> = []
    @State private var showingAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .deleteSelected
    
    // Progress View properties
    @Binding var isImporting: Bool
    @State private var importProgress: Double = 0.0
    @State private var currentImportingFilename: String = ""
    @EnvironmentObject var importingState: ImportingState

    
    
    
    private let spacing: CGFloat = 10
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    
    enum ActiveAlert { case deleteSelected, deleteAll }
    
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
        .navigationTitle("Library")
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
            }
        }
        .sheet(item: $selectedBook) { item in
            NavigationStack {
                VStack {
                    BookSheetView(book: item)
                }
            }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private var content: some View {
        if allBooks.isEmpty {
            emptyLibraryContent
        } else {
            isGalleryView ? AnyView(galleryViewContent) : AnyView(listViewContent)
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
                ForEach(allBooks, id: \.self) { book in
                    bookTile(for: book)
                }
            }
        }
    }
    
    private var listViewContent: some View {
        List(allBooks, id: \.self) { book in
            bookTile(for: book)
        }
    }
    
    private func bookTile(for book: Book) -> some View {
        Button {
            handleBookSelection(book: book)
        } label: {
            BookTileModel(book: book)
                .opacity(isSelecting && !selectedBooks.contains(book) ? 0.5 : 1.0)
        }
    }
    
    private var toolbarContent: some View {
        HStack {
            if isSelecting {
                deleteButton
                doneButton
            } else {
                galleryViewButton
                listViewButton
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
    
    private var galleryViewButton: some View {
        Button(action: {
            isGalleryView = true
        }) {
            Label("Gallery", systemImage: "square.grid.2x2")
        }
    }
    
    private var listViewButton: some View {
        Button(action: {
            isGalleryView = false
        }) {
            Label("List", systemImage: "line.3.horizontal")
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
    
    //    private func handleImportedFiles(urls: [URL]) {
    //        for url in urls {
    //            ComicFileHandler.handleImportedFile(at: url, in: self.viewContext)
    //        }
    //    }
    // Over written for progress view
    
    private func handleImportedFiles(urls: [URL]) {
        importingState.isImporting = true
        let totalFiles = Double(urls.count)
        
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, url) in urls.enumerated() {
                let filename = url.lastPathComponent
                ComicFileHandler.handleImportedFile(at: url, in: self.viewContext)
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
            deleteRelatedEntitiesIfOrphaned(book: book, in: viewContext)
            viewContext.delete(book)
        }
        CoreDataHelper.shared.saveContext(context: viewContext)
        selectedBooks.removeAll()
        isSelecting = false
    }
    
    func deleteAll() {
        for book in allBooks {
            deleteRelatedEntitiesIfOrphaned(book: book, in: viewContext)
            viewContext.delete(book)
        }
        CoreDataHelper.shared.saveContext(context: viewContext)
    }
    
    func deleteRelatedEntitiesIfOrphaned(book: Book, in context: NSManagedObjectContext) {
        // Check Series
        if let series = book.series {
            checkAndDeleteEntity(entity: series, relatedTo: book, byKey: "series", in: context)
        }
        if let storyArcs = book.storyArc as? Set<StoryArc> {
            for storyArc in storyArcs {
                checkAndDeleteEntity(entity: storyArc, relatedTo: book, byKey: "storyArc", in: context)
            }
        }
        
        if let publisher = book.publisher {
            checkAndDeleteEntity(entity: publisher, relatedTo: book, byKey: "publisher", in: context)
        }
        // Add similar checks for other relationships like Publisher, Author, etc.
        // Example:
        // if let publisher = book.publisher {
        //     checkAndDeleteEntity(entity: publisher, relatedTo: book, byKey: "publisher", in: context)
        // }
    }
    
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
