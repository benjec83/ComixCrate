//
//  DiagnosticView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import SwiftUI

struct DiagnosticView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Series.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Series.name, ascending: true)])
    private var allSeries: FetchedResults<Series>
    
    @FetchRequest(entity: Publisher.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Publisher.name, ascending: true)])
    private var allPublishers: FetchedResults<Publisher>

    var body: some View {
        List {
            Section(header: Text("All Series")) {
                ForEach(allSeries, id: \.self) { series in
                    Text(series.name ?? "Unknown Series")
                }
            }
            
            Section(header: Text("All Publishers")) {
                ForEach(allPublishers, id: \.self) { publisher in
                    Text(publisher.name ?? "Unknown Publisher")
                }
            }
        }
    }
}


#Preview {
    DiagnosticView()
}
