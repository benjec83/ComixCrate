//
//  NewLibraryView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

import SwiftUI
import Foundation

struct NewLibraryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)])
    private var books: FetchedResults<Book>
    
    @State private var isGalleryView: Bool = true
    @State private var showingDocumentPicker = false
    @State private var selectedBook: Book? = nil
    
    @State private var isSelecting: Bool = false
    @State private var selectedBooks: Set<Book> = []
    
    @State private var showingAlert: Bool = false
    @StateObject var progressModel = ProgressModel()
    @State private var showingProgressAlert: Bool = false


    enum ActiveAlert { case deleteSelected, deleteAll, progress }

    @State private var activeAlert: ActiveAlert = .deleteSelected
    
    private let spacing: CGFloat = 10
    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    
    var body: some View {
        VStack {
            content
        }
        .overlay(
            Group {
                if showingProgressAlert && !progressModel.isComplete {
                    ProgressAlertView(progressModel: progressModel)
                }
            }
        )
        .toolbar {
            toolbarContent
        }
        .navigationTitle("Library")
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker { urls in
                for url in urls {
                    ComicFileHandler.handleImportedFile(at: url, in: self.viewContext, progressModel: progressModel)
                }
                self.showingProgressAlert = true
            }
        }
        .alert(isPresented: $showingAlert) {
            switch activeAlert {
            case .deleteSelected:
                return Alert(
                    title: Text("Delete Selected Books"),
                    message: Text("Are you sure you want to delete the selected books? This action cannot be undone."),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete"), action: deleteSelectedBooks)
                )
            case .deleteAll:
                return Alert(
                    title: Text("Delete All Books"),
                    message: Text("Are you sure you want to delete all books? This action cannot be undone."),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete All"), action: deleteAll)
                )
            case .progress:
                return Alert(
                    title: Text("Importing..."),
                    message: Text("\(progressModel.currentFileName) (\(progressModel.currentFileNumber) of \(progressModel.totalFiles))"),
                    dismissButton: .cancel()
                )
            }
        }
        .onChange(of: progressModel.isImporting) { newValue in
            if newValue {
                showingAlert = true
                activeAlert = .progress
            } else {
                showingAlert = false
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
    
    @ViewBuilder
    private var content: some View {
        if books.isEmpty {
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
            if isSelecting {
                toggleSelection(for: book)
            } else {
                selectedBook = book
            }
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
    
    private func toggleSelection(for book: Book) {
            if selectedBooks.contains(book) {
                selectedBooks.remove(book)
            } else {
                selectedBooks.insert(book)
            }
        }

        func deleteSelectedBooks() {
            for bookItem in selectedBooks {
                viewContext.delete(bookItem)
            }
            do {
                try viewContext.save()
                selectedBooks.removeAll()
                isSelecting = false
            } catch {
                print("Error deleting selected books:", error.localizedDescription)
            }
        }
    
    func deleteAll() {
        let fetchRequest = Book.fetchRequest()
        do {
            let items = try? viewContext.fetch(fetchRequest)
            for item in items ?? [] {
                viewContext.delete(item)
            }
            try? viewContext.save()
            isSelecting = false
        } catch {
            print("Error deleting all books:", error.localizedDescription)
        }
    }
    
    private func deleteComicFile(at offsets: IndexSet) {
        for index in offsets {
            let book = books[index]
            viewContext.delete(book)
        }
        do {
            try viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

struct ProgressAlertView: View {
    @ObservedObject var progressModel: ProgressModel

    var body: some View {
        VStack {
            Text("Importing...")
            ProgressView(value: progressModel.progress, total: 1.0)
            Text("\(progressModel.currentFileName)")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
