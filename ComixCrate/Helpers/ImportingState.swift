//
//  ImportingState.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/1/23.
//

import SwiftUI
import Combine

class ImportingState: ObservableObject {
    @Published var isImporting: Bool = false
    @Published var importProgress: Double = 0.0
    @Published var currentImportingFilename: String = ""
    @Published var currentBookNumber: Int = 0
    @Published var totalBooks: Int = 0
}
