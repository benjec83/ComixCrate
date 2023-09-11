//
//  MockBook.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/10/23.
//

import Foundation
import SwiftUI
import CoreData

class PreviewCoreDataManager {
    static let shared = PreviewCoreDataManager()

    var container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "MockLibrary") // Replace 'YourModelName' with the name of your Core Data model.
        container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

func createSampleBook(using context: NSManagedObjectContext) -> Book {
    let context = PreviewCoreDataManager.shared.container.viewContext
    
    // Create an instance of Series
    let sampleSeries = Series(context: context)
    sampleSeries.name = "Sample Series Name"
    
    // Create the Book
    let book = Book(context: context)
    book.title = "Sample Book Title"
    book.series = sampleSeries  // Set the series relationship
    book.issueNumber = 2
    
    // Set other properties of the book as needed
    
    return book
}

func createMockManagedContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let container = NSPersistentContainer(name: "MockLibrary") // Replace 'YourModelName' with the name of your Core Data model
    container.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    context.persistentStoreCoordinator = container.persistentStoreCoordinator
    return context
}

