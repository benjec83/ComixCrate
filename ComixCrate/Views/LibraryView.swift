//
//  LibraryView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

import SwiftUI
import Foundation

struct LibraryView: View {
    
    // MARK: - Properties
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)])
    private var books: FetchedResults<Book>
    
    @State private var isGalleryView: Bool = true
    @State private var showingDocumentPicker = false
    @State private var selectedBook: Book? = nil
    @State private var isSelecting: Bool = false
    @State private var selectedBooks: Set<Book> = []
    @State private var showingAlert: Bool = false
    @State private var activeAlert: ActiveAlert = .deleteSelected
    
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
        if books.isEmpty {
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
                ForEach(books, id: \.self) { book in
                    bookTile(for: book)
                }
            }
        }
    }
    
    private var listViewContent: some View {
        List(books, id: \.self) { book in
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
    
    private func handleImportedFiles(urls: [URL]) {
        for url in urls {
            ComicFileHandler.handleImportedFile(at: url, in: self.viewContext)
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
        for bookItem in selectedBooks {
            viewContext.delete(bookItem)
        }
        saveContext()
        selectedBooks.removeAll()
        isSelecting = false
    }
    
    func deleteAll() {
        let fetchRequest = Book.fetchRequest()
        if let items = try? viewContext.fetch(fetchRequest) as? [Book] {
            for item in items {
                viewContext.delete(item)
            }
            saveContext()
            isSelecting = false
        } else {
            print("Error fetching books for deletion.")
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
