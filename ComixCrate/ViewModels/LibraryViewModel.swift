import Foundation
import SwiftUI
import CoreData

class LibraryViewModel: NSObject, ObservableObject {
    @Published var books: [Book] = []
    private var fetchedResultsController: NSFetchedResultsController<Book>
    
    var filter: LibraryFilter  // <-- Add this property

    init(filter: LibraryFilter) {
        self.filter = filter  // <-- Initialize the property here

        let request: NSFetchRequest<Book> = Book.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        switch filter {
        case .allBooks:
            // No predicate needed for all books
            break
        case .favorites:
            request.predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
        case .recentlyAdded:
            request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        case .currentlyReading:
            request.predicate = NSPredicate(format: "read > 0.0 AND read < 100.0")
        }

        let viewContext = PersistenceController.shared.container.viewContext
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)

        super.init()
        
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
            self.books = self.fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items!")
        }
    }
}

extension LibraryViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.books = self?.fetchedResultsController.fetchedObjects ?? []
        }
    }
}

extension LibraryViewModel {
    var navigationTitle: String {
        switch filter {
        case .allBooks:
            return "Library"
        case .favorites:
            return "Favorites"
        case .currentlyReading:
            return "Currently Reading"
        case .recentlyAdded:
            return "Recently Added"
        }
    }
}
