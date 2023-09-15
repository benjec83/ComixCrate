//
//  BookRowModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/13/23.
//

import SwiftUI

struct BookRowModel: View {
    @ObservedObject var book: Book
    

    // MARK: - Computed Properties
    
    private var seriesName: String? {
        book.series?.name
    }
    
    private var publisherName: String? {
        book.publisher?.name
    }
    
    private var storyArcNames: [String] {
        (book.storyArc as? Set<StoryArc>)?.compactMap { $0.name } ?? []
    }

    
    private var bookTitle: String {
        if let title = book.title, !title.isEmpty {
            return "#\(String(book.issueNumber)) - \(title)"
        } else {
            return "#\(String(book.issueNumber))"
        }
    }
    
    private var seriesAndYear: String {
        "\(seriesName ?? "") (\(book.volumeYear))"
    }
    var body: some View {
        VStack {
            
            HStack {
                bookThumbnail
                bookDetails
                Spacer()
                FavoriteButton(book: book, context: book.managedObjectContext ?? PersistenceController.shared.container.viewContext)            }

            .foregroundColor(.secondary)

        }
    }
    
    // MARK: - Subviews
    
    private var bookThumbnail: some View {
        HStack(alignment: .center) {
            ThumbnailProvider(book: book)
                .scaledToFit()
                .frame(width: 50, height: 50)
        }

    }
    
    private var bookDetails: some View {
        VStack(alignment: .leading) {
            Text(bookTitle)
                .font(.subheadline)
                .lineLimit(2)
            
            Text(seriesAndYear)
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

