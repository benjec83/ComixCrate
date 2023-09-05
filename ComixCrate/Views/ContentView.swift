//
//  ContentView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/27/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var isImporting: Bool = false
    @EnvironmentObject var importingState: ImportingState
    
    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Section("Library") {
                        NavigationLink {
                            LibraryView(isImporting: $isImporting)
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
                    }
                    .listStyle(.sidebar )
                    .navigationTitle("Menu")
                }
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

