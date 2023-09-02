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
        NavigationView{
        List {
            ForEach(relatedBookIDs, id: \.self) { bookID in
                if let book = viewContext.object(with: bookID) as? Book {
                    NavigationLink(destination: BookDetailTabs(book: book)) {
                        Text(book.title ?? "Unknown Book")
                    }
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
            return series.book?.allObjects.compactMap { ($0 as? Book)?.objectID } ?? []
        case let publisher as Publisher:
            return publisher.book?.allObjects.compactMap { ($0 as? Book)?.objectID } ?? []
        case let storyArc as StoryArc:
            return storyArc.book?.allObjects.compactMap { ($0 as? Book)?.objectID } ?? []
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
        default:
            return "Related Books"
        }
    }
}

