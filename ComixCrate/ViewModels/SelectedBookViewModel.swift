//
//  SelectedBookViewModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import Foundation
import SwiftUI
import CoreData

class SelectedBookViewModel: ObservableObject {
    @Published var book: Book
    @Published var userRating: Double
    @Published var isFavorite: Bool
    @Published var shouldCacheHighQualityThumbnail: Bool = false

    private var viewContext: NSManagedObjectContext

    init(book: Book, context: NSManagedObjectContext) {
        self.book = book
        self.userRating = Double(book.personalRating) / 2.0
        self.isFavorite = book.isFavorite
        self.viewContext = context
    }

    func markBookAsRead() {
        book.read = 100
        saveContext()
    }

    func markBookAsUnread() {
        book.read = 0
        saveContext()
    }

    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to update read status: \(error)")
        }
    }

    func updateUserRating(to newRating: Double) {
        userRating = newRating
        book.personalRating = newRating
        saveContext()
    }
}

