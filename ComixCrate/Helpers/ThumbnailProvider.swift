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
    let isHighQuality: Bool  // Property to determine if we need a high-quality image
    @Binding var shouldCacheHighQuality: Bool  // Binding to determine if we should cache the high-quality image

    // LRU cache for high-quality images
    static let highQualityImageCache = LRUCache<String, UIImage>(capacity: 20)

    init(book: Book, isHighQuality: Bool = false, shouldCacheHighQuality: Binding<Bool> = .constant(false)) {
        self.book = book
        self.isHighQuality = isHighQuality
        self._shouldCacheHighQuality = shouldCacheHighQuality
        print("ThumbnailProvider: Initialized for book: \(book.title ?? "")")
    }

    var body: some View {
        thumbnailImage
            .onAppear(perform: cacheThumbnailImageIfNeeded)
    }

    private var thumbnailImage: some View {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if isHighQuality {
            if let cachedImage = ThumbnailProvider.highQualityImageCache.get(fullThumbnailPath) {
                print("ThumbnailProvider: Retrieved high-quality image from LRU cache for path: \(fullThumbnailPath)")
                return Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                print("ThumbnailProvider: Retrieved high-quality image from file system for path: \(fullThumbnailPath)")
                ThumbnailProvider.highQualityImageCache.set(fullThumbnailPath, value: uiImage)
                return Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        } else if let cachedImage = ImageCache.shared.image(forKey: fullThumbnailPath) {
            print("ThumbnailProvider: Retrieved thumbnail from cache for path: \(fullThumbnailPath)")
            return Image(uiImage: cachedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
            print("ThumbnailProvider: Retrieved thumbnail from file system for path: \(fullThumbnailPath)")
            return Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }

        print("ThumbnailProvider: Failed to load UIImage from path: \(fullThumbnailPath). Using placeholder image.")
        // Use a placeholder image
        return Image("placeholderCover")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private func cacheThumbnailImageIfNeeded() {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if isHighQuality {
            if shouldCacheHighQuality, ThumbnailProvider.highQualityImageCache.get(fullThumbnailPath) == nil, let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                print("ThumbnailProvider: Caching high quality thumbnail for path: \(fullThumbnailPath)")
                ThumbnailProvider.highQualityImageCache.set(fullThumbnailPath, value: uiImage)
                shouldCacheHighQuality = false // Reset the trigger after caching
            }
        } else if ImageCache.shared.image(forKey: fullThumbnailPath) == nil, let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
            print("ThumbnailProvider: Caching thumbnail for path: \(fullThumbnailPath)")
            ImageCache.shared.set(image: uiImage, forKey: fullThumbnailPath)
        } else {
            print("ThumbnailProvider: Thumbnail already cached for path: \(fullThumbnailPath)")
        }
    }

}
