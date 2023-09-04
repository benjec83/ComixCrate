//
//  CoreDataHelper.swift
//  Comic Reader
//
//  Created by Ben Carney on 8/28/23.
//

import CoreData
import SwiftUI

class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    private init() {}
    
    func saveContext(context: NSManagedObjectContext) {
        print("Attempting to save context...")
        do {
            try context.save()
            print("Context saved successfully.")
        } catch let error as NSError {
            print("Could not save context. \(error), \(error.userInfo)")
        }
    }
}

class CoreDataDeleter {
    let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func deleteObject<T: NSManagedObject>(from fetchedResults: FetchedResults<T>, at offsets: IndexSet) {
        for index in offsets {
            let objectToDelete = fetchedResults[index]
            
            // Delete the object from the context
            viewContext.delete(objectToDelete)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Error deleting object: \(error)")
        }
    }
}


