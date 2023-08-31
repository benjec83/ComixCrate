//
//  ProgressModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

//
//  ProgressModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/30/23.
//

import Foundation
import Combine

class ProgressModel: ObservableObject {
    @Published var isImporting: Bool = false
    @Published var totalFiles: Int = 0
    @Published var currentFileNumber: Int = 0
    @Published var currentFileName: String = ""
    @Published var isComplete: Bool = false

    var progress: Double {
        guard totalFiles > 0 else { return 0.0 }
        return Double(currentFileNumber) / Double(totalFiles)
    }

    func startImporting(totalFiles: Int) {
        self.totalFiles = totalFiles
        self.currentFileNumber = 0
        self.isImporting = true
    }

    func updateProgress(forFile fileName: String) {
        self.currentFileName = fileName
        self.currentFileNumber += 1
        print("Updated progress for file: \(fileName) - \(currentFileNumber)/\(totalFiles)")
    }


    func finishImporting() {
        self.isImporting = false
        self.isComplete = true
    }
}

