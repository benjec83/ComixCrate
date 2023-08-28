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
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

