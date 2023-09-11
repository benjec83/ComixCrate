//
//  FakePublisherLogoView.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/11/23.
//

import SwiftUI

struct FakePublisherLogo: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray)
                .frame(width: 40, height: 40)
            
            Text("P")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}
