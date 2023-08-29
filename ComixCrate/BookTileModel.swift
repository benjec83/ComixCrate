//
//  BookTileModel.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/29/22.
//

import SwiftUI
import CoreData

struct BookTileModel: View {
    let book: Book
    
    /// Computed property to get series name
    var seriesName: String? {
        book.series?.name
    }
    
    /// Computed property to get publisher name
    var publisherName: String? {
        book.publisher?.name
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Spacer()
                ThumbnailProvider(book: book)
                Spacer()
            }
            .shadow(radius: 1)
            .frame(height: 266)
            
            VStack(alignment: .leading) {
                VStack {
                    if let title = book.title, !title.isEmpty {
                        Text("#\(String(book.issueNumber)) - \(title)")
                    } else {
                        Text("#\(book.issueNumber)")
                    }
                }
                .font(.subheadline)
                .lineLimit(2)
                
                Text("\(seriesName ?? "")" + " (" + "\(book.volumeYear)" + ")")
                    .font(.caption2)
                    .lineLimit(1)
                Spacer()
            }
        }
        .frame(width: 180, height: 345)
        .padding()
        .scaledToFit()
        .foregroundColor(.secondary)
        .multilineTextAlignment(.leading)
    }
}
