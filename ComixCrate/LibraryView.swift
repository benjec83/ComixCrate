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
    
    
    @State private var showingDocumentPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var selected: Book? = nil
    
    let spacing: CGFloat = 10
    
    var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    
    
    
    var body: some View {
        HStack {
            Spacer()
            HStack {
                Button {
                    print("Gallery View")
                } label: {
                    Label("Gallery", systemImage: "square.grid.2x2")
                }
                Button {
                    print("List View")
                } label: {
                    Label("List", systemImage: "line.3.horizontal")
                }
            }
            Button {
                print("Filter")
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease")
            }
            Button(action: {
                showingDocumentPicker.toggle()
                print("Add Books")
            }) {
                Label("Add Books", systemImage: "plus.app")
            }
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Label("Delete All Books", systemImage: "trash")
            }
        }
        .padding(.trailing, 40.0)
        .padding(.vertical, 10.0)
        .multilineTextAlignment(.leading)
        .navigationTitle("Library")


        ScrollView(.vertical) {
            if book.isEmpty {
                Text("Please Import Books to Your Library")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .padding()
                Button(action: {
                    showingDocumentPicker.toggle()
                    print("Add Books")
                }) {
                    Label("Click Here to Add Books", systemImage: "plus.app")
                }
            } else {
                LazyVGrid(columns: gridItems, spacing: spacing) {
                    ForEach(book, id: \.self) { item in
                        Button {
                            selected = item
                        } label: {
                            BookTileModel(book: item)
//                            Text("Book")
                        }
                    }
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
        
        
        ///  Start of sheet
//        .sheet(item: $selected) { item in
//                VStack {
//                    Text("Text goes here")
//                
//            }
//        }
        /// End of sheet
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


