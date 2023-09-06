//
//  DiagnosticView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import SwiftUI

struct DiagnosticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // FetchRequest for Series
@FetchRequest(entity: Series.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Series.name, ascending: true)])
    private var allSeries: FetchedResults<Series>
    
    // FetchRequest for Publisher
    @FetchRequest(entity: Publisher.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Publisher.name, ascending: true)])
    private var allPublishers: FetchedResults<Publisher>
    
    // FetchRequest for StoryArc
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.storyArcName, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    // FetchRequest for Events
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.eventName, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    var deleter: CoreDataDeleter {
        CoreDataDeleter(context: viewContext)
    }


    var body: some View {
        List {
            Section(header: Text("All Series")) {
                ForEach(allSeries, id: \.self) { series in
                    NavigationLink(destination: RelatedBooksView(relatedObject: series)) {
                        Text(series.name ?? "Unknown Series")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allSeries, at: offsets)
                })
            }
            
            Section(header: Text("All Publishers")) {
                ForEach(allPublishers, id: \.self) { publisher in
                    NavigationLink(destination: RelatedBooksView(relatedObject: publisher)) {
                        Text(publisher.name ?? "Unknown Publisher")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allPublishers, at: offsets)
                })
            }
            
            Section(header: Text("All Story Arcs")) {
                ForEach(allStoryArcs, id: \.self) { storyArc in
                    NavigationLink(destination: RelatedBooksView(relatedObject: storyArc)) {
                        Text(storyArc.storyArcName ?? "Unknown Story Arc")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allStoryArcs, at: offsets)
                })
            }
            Section(header: Text("All Events")) {
                ForEach(allStoryArcs, id: \.self) { storyArc in
                    NavigationLink(destination: RelatedBooksView(relatedObject: storyArc)) {
                        Text(storyArc.storyArcName ?? "Unknown Story Arc")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allStoryArcs, at: offsets)
                })
            }
        }
    }
}
