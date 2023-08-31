//
//  ThumbnailProvider.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import SwiftUI
import CoreData

struct ThumbnailProvider: View {
    let book: Book
    @State private var image: UIImage?

    init(book: Book) {
        self.book = book
        print("ThumbnailProvider: Initialized for book: \(book.title ?? "")")
    }

    var body: some View {
        Group {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // Use a placeholder image
                Image("placeholderCover")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .onAppear(perform: loadThumbnailImage)
    }

    private func loadThumbnailImage() {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if let cachedImage = ImageCache.shared.image(forKey: fullThumbnailPath) {
            print("ThumbnailProvider: Retrieved thumbnail from cache for path: \(fullThumbnailPath)")
            image = cachedImage
        } else if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
            print("ThumbnailProvider: Retrieved thumbnail from file system for path: \(fullThumbnailPath)")
            image = uiImage
            ImageCache.shared.set(image: uiImage, forKey: fullThumbnailPath)
            print("ThumbnailProvider: Caching thumbnail for path: \(fullThumbnailPath)")
        } else {
            print("ThumbnailProvider: Failed to load UIImage from path: \(fullThumbnailPath). Using placeholder image.")
        }
    }
}
