//
//  BookDetailsMainView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct BookDetailsMainView: View {
    @ObservedObject var book: Book
    @ObservedObject var viewModel: SelectedBookViewModel // Add this line
    @State private var shouldCacheHighQualityThumbnail: Bool = false
    
    public init(book: Book, viewModel: SelectedBookViewModel) {
        self.book = book
        self.viewModel = viewModel
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
                    BookActionButtons(book: book, viewModel: viewModel) // Update this line
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
                Text(book.summary ?? "")
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
