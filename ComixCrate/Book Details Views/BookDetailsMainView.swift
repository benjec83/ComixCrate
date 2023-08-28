//
//  BookDetailsMainView.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/30/22.
//

import SwiftUI

struct BookDetailsMainView: View {
    @EnvironmentObject var modelData: ModelData
    
    var bookIndex: Int {
        modelData.books.firstIndex(where: { $0.id == book.id })!
    }
    
    var book: Book
    
    var body: some View {
        
        ScrollView {
            HStack {
                HStack(alignment: .center) {
                    CoverImage(image: book.image)
                        .scaledToFit()
                    //                        .frame(height: 390.0)
                        .frame(maxWidth: 255)
                        .padding(.all)
                        .shadow(radius: 1)
                }
                VStack {
                    //Book Details
                    
                    // Main Book Details
                    HStack {
                        BookMainDetails(book: book)
                    
//                        FavoriteButton(isSet: $modelData.books[bookIndex].favorite)
                    }
                    // Secondary Book Details
                    BookSecondaryDetails(book: book)
                    
                    //Action Buttons
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
                Text(book.description ?? "")
            }
            .font(.subheadline)
            .padding(.horizontal)
            .frame(maxWidth: 690)
            
        }
    }
}


struct BookDetailsMainView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsMainView(book: books[2])
    }
}

