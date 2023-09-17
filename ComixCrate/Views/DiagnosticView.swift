//
//  DiagnosticView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import SwiftUI

struct DiagnosticView: View {

    @Environment(\.managedObjectContext) private var viewContext
    
    var allEntities: AnyFetchedResults

    
    // FetchRequest for Series
@FetchRequest(entity: BookSeries.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \BookSeries.name, ascending: true)])
    private var allSeries: FetchedResults<BookSeries>
    
    // FetchRequest for Publisher
    @FetchRequest(entity: Publisher.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Publisher.name, ascending: true)])
    private var allPublishers: FetchedResults<Publisher>
    
    // FetchRequest for StoryArc
    @FetchRequest(entity: StoryArc.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \StoryArc.name, ascending: true)])
    private var allStoryArcs: FetchedResults<StoryArc>
    
    // FetchRequest for Events
    @FetchRequest(entity: Event.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Event.name, ascending: true)])
    private var allEvents: FetchedResults<Event>
    
    var deleter: CoreDataDeleter {
        CoreDataDeleter(context: viewContext)
    }

    var body: some View {
        List {
            Section(header: Text("All Series")) {
                ForEach(allSeries, id: \.self) { series in
                    NavigationLink(destination: RelatedBooksView(relatedObject: series, type: .joinEntityEvent, allEntities: allEntities, filter: .allBooks)) {
                        Text(series.name ?? "Unknown Series")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allSeries, at: offsets)
                })
            }
            
            Section(header: Text("All Publishers")) {
                ForEach(allPublishers, id: \.self) { publisher in
                    NavigationLink(destination: RelatedBooksView(relatedObject: publisher, type: .joinEntityEvent, allEntities: allEntities, filter: .allBooks)) {
                        Text(publisher.name ?? "Unknown Publisher")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allPublishers, at: offsets)
                })
            }
            
            Section(header: Text("All Story Arcs")) {
                ForEach(allStoryArcs, id: \.self) { storyArc in
                    NavigationLink(destination: RelatedBooksView(relatedObject: storyArc, type: .joinEntityEvent, allEntities: allEntities, filter: .allBooks)) {
                        Text(storyArc.name ?? "Unknown Story Arc")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allStoryArcs, at: offsets)
                })
            }
            Section(header: Text("All Events")) {
                ForEach(allEvents, id: \.self) { event in
                    NavigationLink(destination: RelatedBooksView(relatedObject: event, type: .joinEntityEvent, allEntities: allEntities, filter: .allBooks)) {
                        Text(event.name ?? "Unknown Event")
                    }
                }
                .onDelete(perform: { offsets in
                    deleter.deleteObject(from: allEvents, at: offsets)
                })
            }
        }
    }
}
