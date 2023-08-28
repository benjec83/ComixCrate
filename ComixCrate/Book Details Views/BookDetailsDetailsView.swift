//
//  BookDetailsDetailsView.swift
//  Comic Reader
//
//  Created by Ben Carney on 12/30/22.
//

import SwiftUI

struct BookDetailsDetailsView: View {
    
    var book: Book

    var body: some View {
        VStack {
            Text(book.title ?? "")
        }
 
    }
}


struct BookDetailsDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        BookDetailsDetailsView(book: books[0])
    }
}
