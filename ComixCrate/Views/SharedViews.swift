//
//  SharedViews.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/1/23.
//

import SwiftUI

struct ImportProgressView: View {
    @Binding var progress: Double
    @Binding var currentFilename: String
    @Binding var currentBookNumber: Int
    @Binding var totalBooks: Int
    
    var body: some View {
        ZStack {
//            // This captures all touch events and blocks interaction with underlying views
//            Color.black.opacity(0.00)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {} // This prevents taps from passing through
            
            VStack(spacing: 20) {
                Text("Importing: \(currentFilename)")
                ProgressView(value: progress)
                Text("\(currentBookNumber)/\(totalBooks)")
                    .font(.caption2)
            }
            .font(.caption)
            .padding()
            .frame(width: 250, height: 120)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

struct ChipsView: View {
    var chips: [String]
    var onDelete: ((String) -> Void)? = nil

    // Define a grid layout with flexible columns.
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
        // Add more GridItems if you want more columns.
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(chips, id: \.self) { chipLabel in
                Chip(label: chipLabel) {
                    onDelete?(chipLabel)
                }
            }
        }
    }
}

struct Chip: View {
    var label: String
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(label)
            if let onDelete = onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(15)
    }
}



