//
//  BookMainDetailsView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct BookMainDetails: View {
    @ObservedObject var book: Book
    
    private var seriesName: String? {
        book.series?.name
    }
    
    private var storyArcNames: [String] {
        guard let bookStoryArcsSet = book.bookStoryArcs as? Set<BookStoryArcs> else {
            return []
        }
        
        return bookStoryArcsSet.compactMap { bookStoryArc in
            return bookStoryArc.storyArc?.name
        }
    }


    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("#\(String(book.issueNumber)) - \(book.title ?? "")")
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("\(seriesName ?? "") (\(String(book.volumeYear)))")
                    .font(.caption2)
                    .lineLimit(2)
                
                Text("Story Arcs: \(storyArcNames.joined(separator: ", ").isEmpty ? "" : storyArcNames.joined(separator: ", "))")

                    .font(.caption2)
                    .fontWeight(.light)
                    .lineLimit(1)
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(width: 360)
    }
}
