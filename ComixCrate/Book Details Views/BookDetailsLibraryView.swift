//
//  BookDetailsLibraryView.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/30/22.
//

import SwiftUI

struct BookDetailsLibraryView: View {
    
    var book: Book
    
    var body: some View {
        VStack {
            Text(book.title ?? "")
        }
    }
}


struct BookDetailsLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsLibraryView(book: books[0])
    }
}
