//
//  BookSheetView.swift
//  Comic Reader
//
//  Created by Ben Carney on 1/1/23.
//

import SwiftUI

struct BookSheetView: View {
    @State private var showingSheet = false
    
    @State var isModalSheetShown: Bool = false
    
    var book: Book
    @Environment(\.dismiss) var dismiss
    

    
    var body: some View {
        
        BookDetailTabs(book: book)
        
    }
}

struct BookSheetView_Previews: PreviewProvider {
    static var previews: some View {
        BookSheetView(book: books[0])
            .environmentObject(ModelData())
    }
}
