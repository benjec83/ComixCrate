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
    
    var body: some View {
        ZStack {
            // This captures all touch events and blocks interaction with underlying views
            Color.black.opacity(0.00)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {} // This prevents taps from passing through
            
            VStack(spacing: 20) {
                Text("Importing: \(currentFilename)")
                ProgressView(value: progress)
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
