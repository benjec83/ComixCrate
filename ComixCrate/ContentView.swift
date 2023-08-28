//
//  ContentView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/27/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                Section("Library") {
                    NavigationLink {
                        LibraryView()
                    } label: {
                        Label("All Books", systemImage: "books.vertical")
                    }
                }
                .listStyle(.sidebar )
                .navigationTitle("Menu")
            }
        }
    }
}
#Preview {
    ContentView()
}
