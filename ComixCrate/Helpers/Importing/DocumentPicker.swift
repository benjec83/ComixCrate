//
//  DocumentPicker.swift
//  ComicFileLoader
//
//  Created by Ben Carney on 8/25/23.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers


struct DocumentPicker: UIViewControllerRepresentable {
    var completion: ([URL]) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.delegate = context.coordinator
        print("DocumentPicker: Starting document picking process.")
        picker.allowsMultipleSelection = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.completion(urls)  // Call the completion closure with the picked URLs
            print("DocumentPicker: Picked documents at URLs: \(urls)")
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("DocumentPicker: Document picking was cancelled.")
        }
    }

}


