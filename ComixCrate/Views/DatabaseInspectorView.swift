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
    @FetchRequest(entity: Characters.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Characters.name, ascending: true)])
    private var characters: FetchedResults<Characters>
    @FetchRequest(entity: BookCreatorRole.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BookCreatorRole.creatorRole, ascending: true)])
    private var bookCreatorRoles: FetchedResults<BookCreatorRole>
    @FetchRequest(entity: Locations.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Locations.name, ascending: true)])
    private var locations: FetchedResults<Locations>
    @FetchRequest(entity: Teams.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Teams.name, ascending: true)])
    private var teams: FetchedResults<Teams>
    
    
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
        NavigationStack {
                List {
                    Section(header: Text("Books")) {
                        ForEach(books, id: \.self) { book in
                            VStack(alignment: .leading) {
                                Text("Title: \(book.title ?? "Unknown")")
                                Text("Issue Number: \(String(book.issueNumber))")
                                Text("Series: \(book.series?.name ?? "Unknown")")
                                Text("Story Arcs: \((book.bookStoryArcs as? Set<BookStoryArcs>)?.compactMap { $0.storyArc?.name }.joined(separator: ", ") ?? "Unknown")")
                                Text("Events: \((book.event as? Set<BookEvents>)?.compactMap { $0.events?.name }.joined(separator: ", ") ?? "Unknown")")
                                Text("Publisher: \(book.publisher?.name ?? "Unknown")")
                                Text("Favorite: \(book.isFavorite ? "Yes" : "No")")
                                Text("Volume Year: \(String(book.volumeYear))")
                                Text("Volume Number: \(String(book.volumeNumber))")
                                Text("Creators: \(creatorsForBook(book: book))")
                                Text("Cover Date: \(dateFormatterWithoutTime.string(from: book.coverDate ?? Date()))")
                                Text("Characters: \((book.characters as? Set<Characters>)?.compactMap { $0.name }.joined(separator: ", ") ?? "Unknown")")
                                Text("Teams: \((book.teams as? Set<Teams>)?.compactMap { $0.name }.joined(separator: ", ") ?? "Unknown")")
                                Text("Locations: \((book.locations as? Set<Locations>)?.compactMap { $0.name }.joined(separator: ", ") ?? "Unknown")")
                                Text("Personal Rating: \(String(book.personalRating))")
                                Text("Date Added: \(dateFormatterWithTime.string(from: book.dateAdded ?? Date()))")
                                Text("Read: \(book.read?.stringValue ?? "N/A")")
                                Text("File Name: \(book.fileName ?? "Unknown")")
                                Text("File Location: \(book.filePath ?? "Unkown")")
                                Text("Thumbnail Path: \(book.thumbnailPath ?? "Unknown")")
                                if let imageData = book.cachedThumbnailData {
                                    Image(uiImage: UIImage(data: imageData) ?? UIImage())
                                } else {
                                    Text("No Thumbnail")
                                }
                            }
                        }
                    }
                    
                    
                    Section(header: Text("Story Arcs")) {
                        ForEach(arcs, id: \.self) { arc in
                            VStack(alignment: .leading) {
                                Text("Story Arc: \(arc.storyArc?.name ?? "N/A")")
                                Text("Part: \(String(arc.storyArcPart))")
                                Text("Book: \(arc.book?.title ?? "N/A")")
                                
                                // Add any other attributes you want to inspect here
                            }
                        }
                    }
                    
                    Section(header: Text("Charcters")) {
                        ForEach(characters, id: \.self) { character in
                            VStack(alignment: .leading) {
                                Text("Character Name: \(character.name ?? "Unknown")")
                                Text("Publisher: \(character.publisher?.name ?? "Unknown")")
                                Text("Books: \(sortedBooksForCharacter(character: character))")
                            }
                        }
                    }
                    Section(header: Text("Locations")) {
                        ForEach(locations, id: \.self) { location in
                            VStack(alignment: .leading) {
                                Text("Character Name: \(location.name ?? "Unknown")")
                                Text("Publisher: \(location.publisher?.name ?? "Unknown")")
                                Text("Books: \(sortedBooksForLocation(location: location))")
                            }
                        }
                    }
                    Section(header: Text("Teams")) {
                        ForEach(teams, id: \.self) { team in
                            VStack(alignment: .leading) {
                                Text("Team Name: \(team.name ?? "Unknown")")
                                Text("Publisher: \(team.publisher?.name ?? "Unknown")")
                                Text("Books: \(sortedBooksForTeam(team: team))")
                            }
                        }
                    }
                }
        }
        .navigationBarTitle("Database Inspector", displayMode: .inline)
    }
    func creatorsForBook(book: Book) -> String {
        guard let bookCreatorRolesSet = book.bookCreatorRole as? Set<BookCreatorRole> else { return "Unknown" }
        let creatorsList = bookCreatorRolesSet.compactMap { role in
            "\(role.creatorRole?.name ?? "Unknown Role"): \(role.creator?.name ?? "Unknown Creator")"
        }
        return creatorsList.joined(separator: ", ")
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
    func sortedBooksForTeam(team: Teams) -> String {
        guard let booksSet = team.books as? Set<Book> else { return "Unknown" }
        let sortedBooks = booksSet.sorted { (book1, book2) in
            if book1.series?.name == book2.series?.name {
                return book1.issueNumber < book2.issueNumber
            }
            return (book1.series?.name ?? "") < (book2.series?.name ?? "")
        }
        return sortedBooks.compactMap { "\($0.series?.name ?? "Unknown") #\($0.issueNumber)" }.joined(separator: ", ")
    }
    func sortedBooksForLocation(location: Locations) -> String {
        guard let booksSet = location.books as? Set<Book> else { return "Unknown" }
        let sortedBooks = booksSet.sorted { (book1, book2) in
            if book1.series?.name == book2.series?.name {
                return book1.issueNumber < book2.issueNumber
            }
            return (book1.series?.name ?? "") < (book2.series?.name ?? "")
        }
        return sortedBooks.compactMap { "\($0.series?.name ?? "Unknown") #\($0.issueNumber)" }.joined(separator: ", ")
    }
    
}
