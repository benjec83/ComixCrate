//
//  RelatedBooksView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/1/23.
//

import SwiftUI
import CoreData

struct RelatedBooksView: View {
    var relatedObject: NSManagedObject
    
    @State private var showBookDetails: Bool = false
    @State private var selectedBook: Book? = nil
    
    


    var body: some View {
        List {
            ForEach(relatedBookIDs, id: \.self) { bookID in
                if let book = viewContext.object(with: bookID) as? Book {
                    NavigationLink(destination: BookDetailTabs(book: book)) {
                        Text("#\(String(book.issueNumber)) - \(book.title ?? "No Title")")
                    }
                }
            }
            
        
    }
        .navigationTitle(relatedObjectName)
    }

    @Environment(\.managedObjectContext) private var viewContext

    var relatedBookIDs: [NSManagedObjectID] {
        switch relatedObject {
        case let series as Series:
            return (series.book?.allObjects as? [Book] ?? [])
            .sorted { $0.issueNumber < $1.issueNumber }
            .compactMap { $0.objectID }
        case let publisher as Publisher:
            // First, sort by series name, then by issue number
            return (publisher.book?.allObjects as? [Book] ?? [])
            .sorted(by: {
                if $0.series?.name == $1.series?.name {
                    return $0.issueNumber < $1.issueNumber
                }
                return $0.series?.name ?? "" < $1.series?.name ?? ""
            }).compactMap { $0.objectID }
        case let storyArc as StoryArc:
            // Fetch the related books through the BookStoryArcs entity and sort by storyArcPart
            return storyArc.booksInArc?.allObjects.sorted(by: {
                let bookArc1 = $0 as! BookStoryArcs
                let bookArc2 = $1 as! BookStoryArcs
                return bookArc1.storyArcPart < bookArc2.storyArcPart
            }).compactMap { ($0 as? BookStoryArcs)?.book?.objectID } ?? []
        default:
            return []
        }
    }




    var relatedObjectName: String {
        switch relatedObject {
        case let series as Series:
            return series.name ?? "Series"
        case let publisher as Publisher:
            return publisher.name ?? "Publisher"
        case let storyArc as StoryArc:
            return storyArc.storyArcName ?? "Story Arc"
        case let event as Event:
            return event.eventName ?? "Event"
        default:
            return "Related Books"
        }
    }
}

