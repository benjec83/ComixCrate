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
    let importingState = ImportingState()

    var body: some Scene {
        WindowGroup {
            ContentView(type: .joinEntityEvent, filter: .allBooks)
                .environmentObject(importingState)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

