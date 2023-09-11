//
//  HomeView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/5/23.
//

import SwiftUI
import UIKit
import CoreData

struct HomeView: View {
    
    @Environment(\.isSearching) var isSearching
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Book.dateAdded, ascending: false)]) private var books: FetchedResults<Book>
    
    @EnvironmentObject var importingState: ImportingState
    @State private var isImporting: Bool = false
    
    let book: Book
    
    var currentlyReading: [Book] {
        books.filter { $0.read > 0.0 && $0.read < 100.0 }
    }
    
    var recentlyAdded: [Book]
    
    var favorites: [Book] {
        books.filter { book in
            (book.isFavorite )
        }
    }
    
    @State private var selected: Book? = nil
    
    let spacing: CGFloat = 10
    
    var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 180))]
    }
    let rows = [
        GridItem(.fixed(1))]
    // MARK: Control number of items per grid
    @State private var currentlyReadingLimit: Int = 4
    @State private var recentlyAddedLimit: Int = 4
    @State private var favoritesLimit: Int = 4
    @State private var readingListsLimit: Int = 4
    var limitedCurrentlyReading: [Book] {
        Array(currentlyReading.prefix(currentlyReadingLimit))
    }
    var limitedRecentlyAdded: [Book] {
        Array(recentlyAdded.prefix(recentlyAddedLimit))
    }
    var limitedFavorites: [Book] {
        Array(favorites.prefix(favoritesLimit))
    }
    var limitedReadingLists: [Book] {
        Array(books.prefix(readingListsLimit))
    }
    
    
    
    var body: some View {
        Text("")
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(/*@START_MENU_TOKEN@*/.large/*@END_MENU_TOKEN@*/)
        
        ScrollView {
            Spacer()
            
            VStack {
                HStack {
                    Text("Currently Reading")
                    Spacer()
                    NavigationLink(destination: LibraryView(isImporting: $isImporting, filter: .currentlyReading)) {
                        Label("View all", systemImage: "chevron.right")
                    }
                }
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                        LazyHGrid(rows: rows) {
                            ForEach(limitedCurrentlyReading) { item in
                                
                                Button {
                                    selected = item
                                } label: {
                                    BookTileModel(book: item)
                                }
                            }
                        }
                        //  Start of sheet
                        .sheet(item: $selected) { item in
                            NavigationStack {
                                VStack {
                                    BookSheetView(book: item)
                                }
                            }
                        }
                        // End of sheet
                    })
            }
            
            VStack {
                HStack {
                    Text("Recently Added")
                    Spacer()
                    Button{
                        print("Recently Added More pressed")
                    } label: {
                        Label("View all", systemImage: "chevron.right")
                    }
                }
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    LazyHGrid(rows: rows) {
                        ForEach(limitedRecentlyAdded) { item in
                            
                            Button {
                                selected = item
                            } label: {
                                BookTileModel(book: item)
                            }
                        }
                    }
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item)
                            }
                        }
                    }
                    // End of sheet
                })
            }
            
            VStack {
                HStack {
                    Text("Favorites")
                    Spacer()
                    NavigationLink(destination: LibraryView(isImporting: $isImporting, filter: .favorites)) {
                        Label("View all", systemImage: "chevron.right")
                    }
                }
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    LazyHGrid(rows: rows) {
                        ForEach(limitedFavorites) { item in
                            
                            Button {
                                selected = item
                            } label: {
                                BookTileModel(book: item)
                            }
                        }
                    }
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item)
                            }
                        }
                    }
                    // End of sheet
                })
            }
            VStack {
                HStack {
                    Text("Reading Lists")
                    Spacer()
                    Button{
                        print("Reading Lists More pressed")
                    } label: {
                        Label("", systemImage: "chevron.right")
                    }
                }
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    LazyHGrid(rows: rows) {
                        ForEach(limitedReadingLists) { item in
                            
                            Button {
                                selected = item
                            } label: {
                                BookTileModel(book: item)
                            }
                        }
                    }
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item)
                            }
                        }
                    }
                    // End of sheet
                })
            }
        }
        .padding(.horizontal, 20.0)
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let mockContext = createMockManagedContext()
        let sampleBook = createSampleBook(using: mockContext)
        
        return HomeView(book: sampleBook, recentlyAdded: [sampleBook])
            .environment(\.managedObjectContext, mockContext)
            .environmentObject(ImportingState())
    }
}


//struct HomeView_Previews: PreviewProvider {
//    static var mockBooks: [Book] {
//        // Create an array of mock Book objects for the preview
//        // You can add more mock books or attributes as needed
//        let book1 = Book(context: PersistenceController.preview.container.viewContext)
//        book1.title = "Sample Book 1"
//        book1.dateAdded = Date()
//        book1.isFavorite = true
//        book1.read = 50.0 // Halfway read
//
//        let book2 = Book(context: PersistenceController.preview.container.viewContext)
//        book2.title = "Sample Book 2"
//        book2.dateAdded = Date().addingTimeInterval(-86400) // Added a day ago
//        book2.isFavorite = false
//        book2.read = 0.0 // Not started
//
//        return [book1, book2]
//    }
//
//    static var previews: some View {
//        HomeView(book: mockBooks[0], recentlyAdded: mockBooks)
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}

