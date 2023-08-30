//
//  CoreDataHelper.swift
//  Comic Reader
//
//  Created by Ben Carney on 8/28/23.
//

import CoreData

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

