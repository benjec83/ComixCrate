////
////  NewView.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/9/23.
////
//
//import SwiftUI
//import CoreData
//
//struct NewView: View {
//    @Binding var book: Book
//    var viewModel: EntityChipTextFieldViewModel  // <-- Add this property
//    
//    @Environment(\.managedObjectContext) private var viewContext
////    @State private var selectedChipType: ChipType
//    @State private var chips: [TempChipData] = []
//
//    @FetchRequest(entity: Book.entity(), sortDescriptors: []) private var bookItems: FetchedResults<Book>
//    
//    init(book: Book, viewModel: EntityChipTextFieldViewModel, entityType: ChipType) {
//        _book = .constant(book)
//        self.viewModel = viewModel  // <-- Store the viewModel
////        _selectedChipType = State(initialValue: entityType) // Initialize selectedChipType with entityType
//    }
//    
//    var body: some View {
//        
//        EntityChipTextFieldView(book: bookItems.first ?? Book(), viewModel: viewModel, type: .bookEvents, chips: $chips, allEntities: AnyFetchedResultsWrapper(BookEvents))
//    }
//}
//
//
//
////#Preview {
////    NewView(book: bookItems.first ?? Book(), viewModel: viewModel,entityType: .storyArc))
////}
