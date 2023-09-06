//
//  NewList.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/6/23.
//

import SwiftUI
import CoreData

enum EntityType {
    case storyArc(storyArcName: String, bookTitles: [String])
    case event(eventName: String, bookTitles: [String])
}


struct NewList: View {
    
    func fetchData(for entityType: EntityType, in context: NSManagedObjectContext) -> [EntityType] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        
        switch entityType {
        case .storyArc:
            fetchRequest = NSFetchRequest(entityName: "BookStoryArcs")
            fetchRequest.relationshipKeyPathsForPrefetching = ["book", "storyArc"]
            
        case .event:
            fetchRequest = NSFetchRequest(entityName: "BookEvents")
            fetchRequest.relationshipKeyPathsForPrefetching = ["books", "events"]
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            
            switch entityType {
            case .storyArc:
                let fetchedResults = results as! [BookStoryArcs]
                return fetchedResults.map {
                    .storyArc(storyArcName: $0.storyArc?.storyArcName ?? "",
                              bookTitles: [$0.book?.title ?? ""])
                }
                
            case .event:
                let fetchedResults = results as! [BookEvents]
                return fetchedResults.map {
                    .event(eventName: $0.events?.eventName ?? "",
                           bookTitles: [$0.books?.title ?? ""])
                }
            }
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }

        // Use static method to fetch data
    static func fetchData(for entityType: EntityType, in context: NSManagedObjectContext) -> [EntityType] {
        let context = PersistenceController.shared.container.viewContext
        return fetchData(for: entityType, in: context) // This will now call the instance method
    }
    
    // Declare entityType as a property of the struct
    let entityType: EntityType

    // This method can now call the static fetchData method without issues
    static func fetchDataStatic(for entityType: EntityType) -> [EntityType] {
            let context = PersistenceController.shared.container.viewContext
            return fetchData(for: entityType, in: context)
        }

        @State private var storyArcData: [EntityType] = fetchDataStatic(for: .storyArc(storyArcName: "", bookTitles: []))
        @State private var eventData: [EntityType] = fetchDataStatic(for: .event(eventName: "", bookTitles: []))


        init(entityType: EntityType) {
            self.entityType = entityType
        }
        
    
    var body: some View {
        List {
            switch entityType {
            case .storyArc(let storyArcName, let bookTitles):
                Section(header: Text("Story Arcs")) {
                    VStack(alignment: .leading) {
                        Text(storyArcName)
                        ForEach(bookTitles, id: \.self) { title in
                            Text(title)
                        }
                    }
                    .contextMenu {
                        Button("Edit") {
                            // Edit action
                        }
                        Button("Delete") {
                            // Delete action
                        }
                    }
                }
            case .event(let eventName, let bookTitles):
                Section(header: Text("Events")) {
                    VStack(alignment: .leading) {
                        Text(eventName)
                        ForEach(bookTitles, id: \.self) { title in
                            Text(title)
                        }
                    }
                    .contextMenu {
                        Button("Edit") {
                            // Edit action
                        }
                        Button("Delete") {
                            // Delete action
                        }
                    }
                }
            }
        }
    }
}



struct NewList_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext

        let mockBook = Book(context: context)
        mockBook.title = "Sample Book"
        mockBook.issueNumber = 1

        return NewList(entityType: .storyArc(storyArcName: "Sample Arc", bookTitles: ["Sample Book"]))
            .environment(\.managedObjectContext, context)
    }
}


