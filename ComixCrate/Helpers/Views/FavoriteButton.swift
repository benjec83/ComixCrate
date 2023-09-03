//
//  FavoriteButton.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import CoreData
import SwiftUI

struct FavoriteButton: View {
    @ObservedObject var book: Book
    var context: NSManagedObjectContext

    var body: some View {
        Button(action: {
            print("Favorite button pressed.")
            withAnimation {
                book.isFavorite.toggle()
                print("Favorite status changed to: \(book.isFavorite)")
                CoreDataHelper.shared.saveContext(context: context)
            }
        }) {
            Image(systemName: book.isFavorite ? "star.fill" : "star")
                .foregroundColor(book.isFavorite ? Color.yellow : Color.accentColor)
        }
    }
}


