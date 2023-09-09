//
//  TestingView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/6/23.
//

import SwiftUI

struct TestingView: View {
    
    //    @Binding var book: Book
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    
    @State private var editedTitle: String = ""
    @State private var editedIssueNumber: Int16?
    @State private var editedSeriesVolume: Int16?
    @State private var editedSeries: String = ""
    @State private var editedBookStoryArc: String = ""
    @State private var editedBookEvent: String = ""
    @State private var editedSummary: String = ""
    @State private var editedCharacters: String = ""
    @State private var editedTeams: String = ""
    @State private var editedLocations: String = ""
    
    var body: some View {
        Form {
            HStack(spacing: 2) {
                VStack(alignment: .leading) {
                    Section {
                        TextField("Title", text: $editedTitle)
                    }header: {
                        Text("Title")
                            .multilineTextAlignment(.leading)
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        Section {
                            TextField("Issue Number", value: $editedIssueNumber, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }header: {
                            Text("Issue Number")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    VStack(alignment: .leading) {
                        Section {
                            TextField("Volume Number", value: $editedSeriesVolume, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                        }header: {
                            Text("Volume Number")
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            VStack(alignment: .leading) {
                Section {
                    TextField("Add a Series", text: $editedSeries)
                }header: {
                    Text("Series")
                        .multilineTextAlignment(.leading)
                }
            }
            HStack(spacing: 2) {
                VStack(alignment: .leading) {
                    Section {
                        TextField("Add a Story Arc", text: $editedBookStoryArc)
                    }header: {
                        Text("Story Arcs")
                            .multilineTextAlignment(.leading)
                    }
                }
                VStack(alignment: .leading) {
                    Section {
                        TextField("Add an Event", text: $editedBookEvent)
                    }header: {
                        Text("Events")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            VStack(alignment: .leading) {
                Section {
                    TextEditor(text: $editedSummary)
                        .frame(minHeight: 150, alignment: .top)
                }header: {
                    Text("Summary")
                }
            }
            Section {
                HStack {
                    VStack(alignment: .leading) {
                        Section {
                            TextField("Add Characters", text: $editedCharacters)
                        }header: {
                            Text("Characters")
                        }
                    }
                    VStack(alignment: .leading) {
                        Section {
                            TextField("Add Teams", text: $editedTeams)
                        }header: {
                            Text("Teams")
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Section {
                        TextField("Add Locations", text: $editedLocations)
                    }header: {
                        Text("Locations")
                    }
                }
            }
            .navigationTitle("Edit Book Details")
            .navigationBarTitleDisplayMode(.automatic)
        }
        
    }
    
}

#Preview {
    TestingView()
}
