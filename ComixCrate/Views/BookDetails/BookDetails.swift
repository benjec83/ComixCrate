//
//  BookDetailsView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI
import CoreData

struct BookDetails: View {
    @ObservedObject var viewModel: SelectedBookViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite: Bool
    @State private var isEditing: Bool = false
    @ObservedObject var book: Book
    
    public init(book: Book, viewModel: SelectedBookViewModel) {
        self.book = book
        self.viewModel = viewModel
        _isFavorite = State(initialValue: book.isFavorite)
    }
    
    private var seriesName: String? {
        book.series?.name
    }
    
    var body: some View {
        TabView {
            BookDetailsMainView(book: book, viewModel: viewModel)
                .tabItem {
                    Image(systemName: "info")
                    Text("Information")
                }
            BookDetailsCreativesView(book: book)
                .tabItem {
                    Image(systemName: "photo.artframe")
                    Text("Creative Team")
                }
            BookDetailsMoreView(book: book)
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
        .navigationTitle(bookTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                HStack {
            Button {
                isEditing = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .sheet(isPresented: $isEditing) {
                EditBookView(book: book, viewModel: viewModel, context: viewContext)
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
    var bookTitle: String {
        return "#" + "\(String(book.issueNumber))" + " - " + "\(book.title ?? book.series?.name ?? "")"
    }
}


