//
//  BookDetailsCreativesView.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/30/22.
//

import SwiftUI

struct BookDetailsCreativesView: View {
    var book: Book
    
    var body: some View {
        VStack {
            Text(book.title ?? "")
        }
    }
}

struct BookDetailsCreativesView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsCreativesView(book: books[0])
    }
}
