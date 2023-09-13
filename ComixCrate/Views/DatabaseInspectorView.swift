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
    @FetchRequest(entity: BookStoryArcs.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BookStoryArcs.storyArc, ascending: true)])
    private var arcs: FetchedResults<BookStoryArcs>
    @FetchRequest(entity: Characters.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Characters.characterName, ascending: true)])
    private var characters: FetchedResults<Characters>
    
    let dateFormatterWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    let dateFormatterWithoutTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    var body: some View {
        List {
            ForEach(books, id: \.self) { book in
                VStack(alignment: .leading) {
                    Text("Title: \(book.title ?? "Unknown")")
                    Text("Issue Number: \(String(book.issueNumber))")
                    Text("Series: \(book.series?.name ?? "Unknown")")
                    Text("Story Arcs: \((book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap { $0.storyArc?.storyArcName }.joined(separator: ", ") ?? "Unknown")")
                    Text("Publisher: \(book.publisher?.name ?? "Unknown")")
                    Text("Favorite: \(book.isFavorite ? "Yes" : "No")")
                    Text("Volume Year: \(String(book.volumeYear))")
                    Text("Volume Number: \(String(book.volumeNumber))")
                    Text("Date Added: \(dateFormatterWithTime.string(from: book.dateAdded ?? Date()))")
                    Text("Read: \(String(book.read))")
                    Text("Personal Rating: \(String(book.personalRating))")
                    Text("File Name: \(book.fileName ?? "Unknown")")
                    Text("File Location: \(book.filePath ?? "Unkown")")
                    Text("Cover Date: \(dateFormatterWithoutTime.string(from: book.coverDate ?? Date()))")
                    Text("Characters: \((book.characters as? Set<Characters>)?.compactMap { $0.characterName }.joined(separator: ", ") ?? "Unknown")")
                    
                    
                    // Add any other attributes you want to inspect here
                }
            }
        }
        List {
            ForEach(arcs, id: \.self) { arc in
                VStack(alignment: .leading) {
                    Text("Story Arc: \(arc.storyArc?.storyArcName ?? "N/A")")
                    Text("Part: \(String(arc.storyArcPart))")
                    Text("Book: \(arc.book?.title ?? "N/A")")
                    
                    // Add any other attributes you want to inspect here
                }
            }
        }
        List {
            ForEach(characters, id: \.self) { character in
                VStack(alignment: .leading) {
                    Text("Character Name: \(character.characterName ?? "Unknown")")
                    Text("Publisher: \(character.publisher?.name ?? "Unknown")")
                    Text("Books: \(sortedBooksForCharacter(character: character))")
                }
            }
        }
        
        .navigationBarTitle("Database Inspector", displayMode: .inline)
        
        
        
    }
    
    
    func sortedBooksForCharacter(character: Characters) -> String {
        guard let booksSet = character.books as? Set<Book> else { return "Unknown" }
        let sortedBooks = booksSet.sorted { (book1, book2) in
            if book1.series?.name == book2.series?.name {
                return book1.issueNumber < book2.issueNumber
            }
            return (book1.series?.name ?? "") < (book2.series?.name ?? "")
        }
        return sortedBooks.compactMap { "\($0.series?.name ?? "Unknown") #\($0.issueNumber)" }.joined(separator: ", ")
    }
}
