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
    @ObservedObject var viewModel: SelectedBookViewModel

    @State private var showingSheet = false
    @State var isModalSheetShown: Bool = false
    @Environment(\.dismiss) var dismiss

    init(book: Book) {
        self.book = book
        self.viewModel = SelectedBookViewModel(book: book, context: PersistenceController.shared.container.viewContext)
    }

    var body: some View {
        BookDetails(book: book, viewModel: viewModel)
    }
}


