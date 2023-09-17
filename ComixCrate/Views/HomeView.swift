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
    var allEntities: AnyFetchedResults
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Book.dateAdded, ascending: false)]) private var books: FetchedResults<Book>
    
    @EnvironmentObject var importingState: ImportingState
    @Binding var isImporting: Bool
    
    //    let book: Book
    
    var currentlyReading: [Book] {
        let lowerBound = NSDecimalNumber(value: 0.0)
        let upperBound = NSDecimalNumber(value: 100.0)
        
        return books.filter { book in
            guard let readValue = book.read else { return false }
            return readValue.compare(lowerBound) == .orderedDescending && readValue.compare(upperBound) == .orderedAscending
        }
    }


    
    var recentlyAdded: [Book] {
        Array(books.filter { $0.dateAdded != nil }.sorted(by: { $0.dateAdded! > $1.dateAdded! }).prefix(10))
    }
    
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
    
    init(isImporting: Binding<Bool>, context: NSManagedObjectContext, allEntities: AnyFetchedResults) {
        self._isImporting = isImporting
        //            self.recentlyAdded = recentlyAdded
        self.allEntities = allEntities
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
                    NavigationLink(destination: LibraryView(filter: .currentlyReading, isImporting: $isImporting, type: .joinEntityEvent, allEntities: allEntities)) {
                        Label("View all", systemImage: "chevron.right")
                    }
                }
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    LazyHGrid(rows: rows) {
                        ForEach(limitedCurrentlyReading) { item in
                            BookTileModel(book: item)
                                .onTapGesture(count: 2) {
                                    selected = item
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
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item, type: .joinEntityEvent, allEntities: allEntities)
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
                            BookTileModel(book: item)
                                .onTapGesture(count: 2) {
                                    selected = item
                                }
                        }
                    }
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item, type: .joinEntityEvent, allEntities: allEntities)
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
                    NavigationLink(destination: LibraryView(filter: .favorites, isImporting: $isImporting, type: .joinEntityEvent, allEntities: allEntities)) {
                        Label("View all", systemImage: "chevron.right")
                    }
                }
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
                    LazyHGrid(rows: rows) {
                        ForEach(limitedFavorites) { item in
                            BookTileModel(book: item)
                                .onTapGesture(count: 2) {
                                    selected = item
                                }
                        }
                    }
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item, type: .joinEntityEvent, allEntities: allEntities)
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
                            BookTileModel(book: item)
                                .onTapGesture(count: 2) {
                                    selected = item
                                }
                        }
                    }
                    //  Start of sheet
                    .sheet(item: $selected) { item in
                        NavigationStack {
                            VStack {
                                BookSheetView(book: item,  type: .joinEntityEvent, allEntities: allEntities)
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
