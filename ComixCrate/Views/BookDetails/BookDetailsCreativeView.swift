//
//  BookDetailsCreativeView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct BookDetailsCreativesView: View {
    @ObservedObject var book: Book
    
    public var body: some View {
        VStack {
            Text(book.title ?? "")
            Text("Creatives View")
        }
    }
}
