//
//  Persistence.swift
//  ComicFileLoader
//
//  Created by Ben Carney on 8/25/23.
//

import CoreData

struct PersistenceController {
    static let shared: PersistenceController = {
        let instance = PersistenceController()
        return instance
    }()

    var container: NSPersistentContainer = {
        print("Initializing NSPersistentContainer...")
        let container = NSPersistentContainer(name: "LibraryData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("NSPersistentContainer initialized successfully.")
            }
        })
        return container
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LibraryData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("Core Data stack has been initialized with description: \(storeDescription)")
            
            // Log the file path for the persistent store
            if let url = storeDescription.url {
                print("Persistent store file path: \(url)")
            }
        })
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Add any mock data or setup here if needed
        return result
    }()
}



