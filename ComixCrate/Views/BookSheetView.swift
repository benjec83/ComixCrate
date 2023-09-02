//
//  BookSheetView.swift
//  Comic Reader
//
//  Created by Ben Carney on 1/1/23.
//

import SwiftUI
import CoreData

struct BookSheetView: View {
    
    @ObservedObject var book: Book

    @State private var showingSheet = false
    
    @State var isModalSheetShown: Bool = false
    
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        
        BookDetailTabs(book: book)
        
    }
}

//struct BookSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        BookSheetView(book: books[0])
//            .environmentObject(ModelData())
//    }
//}
