//
//  ContentView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/27/23.
//

import SwiftUI
import CoreData

enum LibraryFilter {
    case all
    case favorites
    case currentlyReading
    // Add other cases as needed
}

struct ContentView: View {
    @State private var isImporting: Bool = false
    @EnvironmentObject var importingState: ImportingState
    @FetchRequest(entity: Book.entity(), sortDescriptors: []) private var bookItems: FetchedResults<Book>
    @State private var chips: [TempChipData] = []

    
    // Added for testing EntityChipTextFieldView - delete when finished
    @State private var text: String = ""
    var viewModel: EntityChipTextFieldViewModel = EntityChipTextFieldViewModel()
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Section("Library") {
                        NavigationLink {
                            HomeView(book: bookItems.first ?? Book(), recentlyAdded: Array(bookItems))
                        } label: {
                            Label("Home", systemImage: "house.fill")
                        }
                        NavigationLink {
                            LibraryView(isImporting: $isImporting, filter: .all)
                        } label: {
                            Label("Library", systemImage: "books.vertical")
                        }
                        
                        NavigationLink {
                            LibraryView(isImporting: $isImporting, filter: .favorites)
                        } label: {
                            Label("Favorites", systemImage: "star")
                        }
                        NavigationLink(destination: TestingView()) {
                            Label("New Edit Sheet", systemImage: "list.bullet.rectangle.portrait")
                        }
                    }
                    Section("Reading Lists", content: {
                        NavigationLink {Text("All Reading Lists")} label: {
                            Label("All Reading Lists", systemImage: "list.bullet.rectangle")
                        }
                        NavigationLink {Text("User Reading List 1")} label: {
                            Label("User Reading List 1", systemImage: "list.bullet.rectangle.portrait")
                        }
                        NavigationLink {Text("User Reading List 2")} label: {
                            Label("User Reading List 2", systemImage: "list.bullet.rectangle.portrait")
                        }
                        NavigationLink {Text("User Reading List 3")} label: {
                            Label("User Reading List 3", systemImage: "list.bullet.rectangle.portrait")
                        }
                        NavigationLink {Text("Add New List")} label: {
                            Label("Add New List", systemImage: "doc.badge.plus")
                        }
                        
                    })
                    .listStyle(.sidebar )
                    .navigationTitle("Menu")
                    Spacer()
                    NavigationLink {
                        DatabaseInspectorView()
                    } label: {
                        Label("Database Inspector", systemImage: "tablecells")
                    }
                    NavigationLink {
                        DiagnosticView()
                    } label: {
                        Label("DiagnosticView", systemImage: "gear.badge.questionmark")
                    }
                    NavigationLink {Text("Settings")} label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                HomeView(book: bookItems.first ?? Book(), recentlyAdded: Array(bookItems))
            }
            // Blocking overlay
            if importingState.isImporting {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {} // This prevents taps from passing through
            }
            
            // Progress bar
            if importingState.isImporting {
                ImportProgressView(progress: $importingState.importProgress, currentFilename: $importingState.currentImportingFilename, currentBookNumber: $importingState.currentBookNumber, totalBooks: $importingState.totalBooks)
            }
        }
    }
    var blockingOverlay: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {} // This prevents taps from passing through
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
////        let mockContext = createMockManagedContext()
////        let sampleBook = createSampleBook(using: PreviewCoreDataManager.shared.container.viewContext)
//        let importingState = ImportingState() // Create a default instance of ImportingState
//        
//        return ContentView()
//            .environment(\.managedObjectContext, mockContext)
//            .environmentObject(importingState)
//    }
//}
