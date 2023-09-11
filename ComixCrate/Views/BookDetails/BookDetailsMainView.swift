//
//  BookDetailsMainView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct BookDetailsMainView: View {
    @ObservedObject var book: Book
    @State private var shouldCacheHighQualityThumbnail: Bool = false
    
    public init(book: Book) {
        self.book = book
    }
    
    public var body: some View {
        
        ScrollView {
            HStack {
                HStack(alignment: .center) {
                    ThumbnailProvider(book: book, isHighQuality: true, shouldCacheHighQuality: $shouldCacheHighQualityThumbnail)
                        .scaledToFit()
                        .frame(height: 390.0)
                        .frame(maxWidth: 255)
                        .padding(.all)
                        .shadow(radius: 1)
                }
                VStack {
                    BookMainDetails(book: book)
                    BookSecondaryDetails(book: book)
                    BookActionButtons(book: book)
                }
                .padding(.all)
                .frame(width: 380)
            }
            .frame(width: 710)
            
            Divider()
                .padding(.horizontal, 30.0)
            VStack(alignment: .leading) {
                HStack {
                    Text("Description:")
                        .fontWeight(.semibold)
                        .padding(.bottom, 5.0)
                    Spacer()
                }
                Text(book.sypnosis ?? "")
            }
            .font(.subheadline)
            .padding(.horizontal)
            .frame(maxWidth: 690)
            
        }
        .onAppear {
            shouldCacheHighQualityThumbnail = true
        }
    }
}
