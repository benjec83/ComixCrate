//
//  ReadingListsView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/5/23.
//

import SwiftUI

struct ReadingListsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var bookItems: FetchedResults<Book>
    
    var body: some View {
        Text("Reading List View")
            .navigationTitle("Reading Lists")
    }
}

struct ReadingListsView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingListsView()
    }
}
