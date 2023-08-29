//
//  DatabaseInspectorView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import SwiftUI
import CoreData

struct DatabaseInspectorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)])
    private var books: FetchedResults<Book>
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    
    var body: some View {
        List {
            ForEach(books, id: \.self) { book in
                VStack(alignment: .leading) {
                    Text("Title: \(book.title ?? "Unknown")")
                    Text("Issue Number: \(String(book.issueNumber))")
                    Text("Series: \(book.series?.name ?? "Unknown")")
                    Text("Publisher: \(book.publisher?.name ?? "Unknown")")
                    Text("Favorite: \(book.isFavorite ? "Yes" : "No")")
                    Text("Volume Year: \(String(book.volumeYear))")
                    Text("Volume Number: \(String(book.volumeNumber))")
                    Text("Date Added: \(dateFormatter.string(from: book.dateAdded ?? Date()))")

                    // Add any other attributes you want to inspect here
                }
            }
        }
        .navigationBarTitle("Database Inspector", displayMode: .inline)
    }
}
