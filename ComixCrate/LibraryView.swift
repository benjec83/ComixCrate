//
//  LibraryView.swift
//  Comic Reader
//
//  Created by Ben Carney on 1/1/23.
//

import SwiftUI
import Foundation

struct LibraryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)])
    private var book: FetchedResults<Book>
    
    @State private var isGalleryView: Bool = true
    @State private var showingDocumentPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var selected: Book? = nil
    
    @State private var isSelecting: Bool = false
    @State private var selectedBooks: Set<Book> = []
    
    @State private var showingDeleteSelectedConfirmation = false
    
    
    let spacing: CGFloat = 10
    
    var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                if book.isEmpty {
                    Text("Please Import Books to Your Library")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .padding()
                    Button(action: {
                        showingDocumentPicker.toggle()
                    }) {
                        Label("Click Here to Add Books", systemImage: "plus.app")
                    }
                } else {
                    if isGalleryView {
                        LazyVGrid(columns: gridItems, spacing: spacing) {
                            ForEach(book, id: \.self) { item in
                                Button {
                                    if isSelecting {
                                        if selectedBooks.contains(item) {
                                            selectedBooks.remove(item)
                                        } else {
                                            selectedBooks.insert(item)
                                        }
                                    } else {
                                        selected = item
                                    }
                                } label: {
                                    BookTileModel(book: item)
                                        .opacity(isSelecting && !selectedBooks.contains(item) ? 0.5 : 1.0) // Visual feedback for selection
                                }
                            }
                        }
                        .onAppear {
                            print("Number of books: \(book.count)")
                        }
                    } else {
                        HStack {
                            Text("Text")
                                .font(.headline)
                                .background(Color.red)
                            List {
                                Text("Book 1")
                                Text("Book 2")
                                Text("Book 3")
                            }
                        }
                        .background(Color.red)
                    }
                }
            }
            .sheet(isPresented: $showingDocumentPicker) {
                DocumentPicker { urls in
                    for url in urls {
                        ComicFileHandler.handleImportedFile(at: url, in: self.viewContext)
                    }
                }
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete All Books"),
                    message: Text("Are you sure you want to delete all books? This action cannot be undone."),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete All")) {
                        deleteAll()
                    }
                )
            }
            .alert(isPresented: $showingDeleteSelectedConfirmation) {
                Alert(
                    title: Text("Delete Selected Books"),
                    message: Text("Are you sure you want to delete the selected books? This action cannot be undone."),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete")) {
                        deleteSelectedBooks()
                    }
                )
            }
            .sheet(item: $selected) { item in
                NavigationStack {
                    VStack {
                        BookSheetView(book: item)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if !isSelecting {
                        Button {
                            isGalleryView = true
                            print("Gallery View")
                        } label: {
                            Label("Gallery", systemImage: "square.grid.2x2")
                        }
                        Button {
                            isGalleryView = false
                            print("List View")
                        } label: {
                            Label("List", systemImage: "line.3.horizontal")
                        }
                        Button {
                            print("Filter")
                        } label: {
                            Label("Filter", systemImage: "line.3.horizontal.decrease")
                        }
                        Button(action: {
                            showingDocumentPicker.toggle()
                        }) {
                            Label("Add Books", systemImage: "plus.app")
                        }
                    }
                    
                    if isSelecting {
                        Button(action: {
                            showingDeleteSelectedConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: {
                            isSelecting.toggle()
                            selectedBooks.removeAll() // Clear selections when toggling
                        }) {
                            if isSelecting {
                                Text("Done")
                            } else {
                                Image(systemName: "checkmark.square")
                            }
                        }
                }
            }
        }
        .navigationTitle("Library")
    }
    
    func deleteSelectedBooks() {
        for bookItem in selectedBooks {
            viewContext.delete(bookItem)
        }
        do {
            try viewContext.save()
            selectedBooks.removeAll() // Clear the set after deletion
            isSelecting = false
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
        } catch {
            print("Error deleting all books:", error.localizedDescription)
        }
    }
    private func deleteComicFile(at offsets: IndexSet) {
        for index in offsets {
            let book = book[index]
            viewContext.delete(book)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
