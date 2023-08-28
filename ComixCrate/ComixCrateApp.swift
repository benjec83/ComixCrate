//
//  ComixCrateApp.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/27/23.
//

import SwiftUI

@main
struct ComixCrateApp: App {
    // Initialize the Core Data stack
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Provide the main context to the SwiftUI environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

