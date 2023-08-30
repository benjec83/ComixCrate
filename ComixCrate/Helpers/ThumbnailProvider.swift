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

    init(book: Book) {
        self.book = book
        print("ThumbnailProvider: Initialized for book: \(book.title ?? "")")
    }

    var body: some View {
        thumbnailImage
            .onAppear(perform: cacheThumbnailImageIfNeeded)
    }

    private var thumbnailImage: some View {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if let cachedImage = ImageCache.shared.image(forKey: fullThumbnailPath) {
            print("ThumbnailProvider: Retrieved thumbnail from cache for path: \(fullThumbnailPath)")
            return Image(uiImage: cachedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            print("ThumbnailProvider: Thumbnail not found in cache for path: \(fullThumbnailPath)")
            if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                print("ThumbnailProvider: Retrieved thumbnail from file system for path: \(fullThumbnailPath)")
                return Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                print("ThumbnailProvider: Failed to load UIImage from path: \(fullThumbnailPath). Using placeholder image.")
                // Use a placeholder image
                return Image("placeholderCover")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }

    private func cacheThumbnailImageIfNeeded() {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if ImageCache.shared.image(forKey: fullThumbnailPath) == nil, let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
            print("ThumbnailProvider: Caching thumbnail for path: \(fullThumbnailPath)")
            ImageCache.shared.set(image: uiImage, forKey: fullThumbnailPath)
        } else {
            print("ThumbnailProvider: Thumbnail already cached for path: \(fullThumbnailPath)")
        }
    }
}





