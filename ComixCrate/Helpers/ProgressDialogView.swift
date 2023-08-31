//
//  ProgressDialogView.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

import SwiftUI

struct ProgressDialogView: View {
    @ObservedObject var progressModel: ProgressModel

    var body: some View {
        VStack {
            Text("Importing \(progressModel.currentFileName)")
            ProgressView(value: progressModel.progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            Text("\(progressModel.currentFileNumber) of \(progressModel.totalFiles) files processed")
        }
        .padding()
    }
}

