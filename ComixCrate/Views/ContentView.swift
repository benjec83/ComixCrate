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
                    NavigationLink {
                        NewLibraryView()
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

