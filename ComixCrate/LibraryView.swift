//
//  LibraryView.swift
//  Comic Reader
//
//  Created by Ben Carney on 1/1/23.
//

import SwiftUI
import Foundation

struct LibraryView: View {
    
    @EnvironmentObject var manager: DataManager
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var bookItems: FetchedResults<Book>
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.isSearching) var isSearching
    
    @State var focus: String
    
    var library = ComicLibrary()
    
    var SearchType: String {
        switch(focus) {
        case "Favorites":
            return "favorite"
        case "Recently Added":
            return "read"
        default:
            return ""
        }
    }
    
    @State var searchQuery = ""
    var filteredBooks: [Book] {
        if searchQuery.isEmpty {
            return library.library
        } else {
            return library.library.filter {
                $0.series.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
    
    let book: Book
    let books: [Book]
    
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
        }
        .padding(.trailing, 40.0)
        .padding(.vertical, 10.0)


        .multilineTextAlignment(.leading)
        .navigationTitle("\(focus)")


        ScrollView(.vertical) {

            LazyVGrid(columns: gridItems,
                      spacing: spacing
            )

            { ForEach(filteredBooks) { item in

                Button {
                    selected = item
                } label: {
                    BookTileModel(book: item)
                }
            }
            }
        }
        .searchable(text: $searchQuery, placement: .navigationBarDrawer, prompt: "Search")
        //  Start of sheet
        .sheet(item: $selected) { item in
            NavigationStack {
                VStack {
                    BookSheetView(book: item)
                }
            }
        }
        // End of sheet
    }
}


