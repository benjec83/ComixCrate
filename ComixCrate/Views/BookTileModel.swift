//
//  BookTileModel.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/29/22.
//

import SwiftUI
import CoreData

struct BookTileModel: View {
    @ObservedObject var book: Book

    // MARK: - Computed Properties
    
    private var seriesName: String? {
        book.bookSeries?.name
    }
    
    private var publisherName: String? {
        book.publisher?.name
    }
    
    private var storyArcNames: [String] {
        (book.arcJoins as? Set<StoryArc>)?.compactMap { $0.name } ?? []
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
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            bookThumbnail
            bookDetails
        }
        .frame(width: 180, height: 345)
        .padding()
        .scaledToFit()
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
    }
    
    // MARK: - Subviews
    
    private var bookThumbnail: some View {
        HStack(alignment: .center) {
            Spacer()
            ThumbnailProvider(book: book)
            Spacer()
        }
        .shadow(radius: 1)
        .frame(height: 266)
    }
    
    private var bookDetails: some View {
        VStack(alignment: .leading) {
            Text(bookTitle)
                .font(.subheadline)
                .lineLimit(2)
            
            Text(seriesAndYear)
                .font(.caption2)
                .lineLimit(1)
            
            Spacer()
        }
    }
}
