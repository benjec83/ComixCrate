//
//  ThumbnailProvider.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/28/23.
//

import SwiftUI
import CoreData

struct ThumbnailProvider: View {
    @ObservedObject var book: Book
    let isHighQuality: Bool  // Property to determine if we need a high-quality image
    @Binding var shouldCacheHighQuality: Bool  // Binding to determine if we should cache the high-quality image

    // LRU cache for high-quality images
    static let highQualityImageCache = LRUCache<String, UIImage>(capacity: 20)

    init(book: Book, isHighQuality: Bool = false, shouldCacheHighQuality: Binding<Bool> = .constant(false)) {
        print("ThumbnailProvider: Initializing for book: \(book.title ?? "Unknown Title")")
        self.book = book
        self.isHighQuality = isHighQuality
        self._shouldCacheHighQuality = shouldCacheHighQuality
        print("ThumbnailProvider: Initialized for book: \(book.title ?? "")")
    }

    var body: some View {
        
        thumbnailImage
            .onAppear(perform: {
                print("ThumbnailProvider: Executing body for book: \(book.title ?? "Unknown Title")")
                cacheThumbnailImageIfNeeded()
            })
    }

    private var thumbnailImage: some View {
        if let thumbnailPath = book.thumbnailPath {
            let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            print("ThumbnailProvider: Base path is: \(basePath)")
            
            if book.thumbnailPath == nil {
                print("Warning: thumbnailPath is nil for book: \(book.title ?? "Unknown Title")")
            }
            
            let fullThumbnailPath = basePath.appendingPathComponent(thumbnailPath).path
            print("ThumbnailProvider: Full thumbnail path is: \(fullThumbnailPath)")
            print("Attempting to display thumbnail from path: \(fullThumbnailPath) for book: \(book.title ?? "Unknown Title")")
            
            let fileExists = FileManager.default.fileExists(atPath: fullThumbnailPath)
            print("ThumbnailProvider: Does file exist at path \(fullThumbnailPath)? \(fileExists)")
            if !fileExists {
                print("ThumbnailProvider: File does not exist. Possible reasons: Incorrect path, file not yet created, file deleted, or file access issues.")
            }
            
            if isHighQuality {
                let isCached = ThumbnailProvider.highQualityImageCache.get(fullThumbnailPath)
                print("ThumbnailProvider: Is image cached for path \(fullThumbnailPath)? \(isCached)")
                
                if let cachedImage = ThumbnailProvider.highQualityImageCache.get(fullThumbnailPath) {
                    print("ThumbnailProvider: Retrieved high-quality image from LRU cache for path: \(fullThumbnailPath) for book: \(book.fileName ?? "Unknown File")")
                    return AnyView(Image(uiImage: cachedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit))
                } else if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                    print("ThumbnailProvider: Successfully initialized UIImage from path: \(fullThumbnailPath)")
                    print("ThumbnailProvider: Retrieved high-quality image from file system for path: \(fullThumbnailPath) for book: \(book.fileName ?? "Unknown File")")
                    ThumbnailProvider.highQualityImageCache.set(fullThumbnailPath, value: uiImage)
                    print("ThumbnailProvider: Inserted image into cache for path: \(fullThumbnailPath)")
                    return AnyView(Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit))
                } else {
                    print("ThumbnailProvider: Failed to initialize UIImage from path: \(fullThumbnailPath)")
                    print("Error: Failed to load thumbnail from path: \(fullThumbnailPath) for book: \(book.fileName ?? "Unknown File")")
                    print("ThumbnailProvider: Image initialization failed. Possible reasons: Corrupted file, unsupported format, or file access issues.")
                }
            } else {
                if let cachedImage = ImageCache.shared.image(forKey: fullThumbnailPath) {
                    print("ThumbnailProvider: Successfully retrieved image from shared cache for path: \(fullThumbnailPath)")
                    return AnyView(Image(uiImage: cachedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit))
                } else if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                    print("ThumbnailProvider: Successfully initialized UIImage from path: \(fullThumbnailPath)")
                    return AnyView(Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit))
                } else {
                    print("ThumbnailProvider: Failed to initialize UIImage from path: \(fullThumbnailPath)")
                }
            }
            
            print("ThumbnailProvider: Failed to load UIImage for book: \(book.fileName ?? "Unknown File") from path: \(fullThumbnailPath). Using placeholder image.")
            return AnyView(Image("placeholderCover")
                .resizable()
                .aspectRatio(contentMode: .fit))
        } else {
            print("ThumbnailProvider: thumbnailPath is nil. Exiting early.")
            return AnyView(Image("placeholderCover")) // or another appropriate fallback
        }
    }


    private func cacheThumbnailImageIfNeeded() {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if isHighQuality {
            if shouldCacheHighQuality, ThumbnailProvider.highQualityImageCache.get(fullThumbnailPath) == nil, UIImage(contentsOfFile: fullThumbnailPath) != nil {
                print("ThumbnailProvider: Caching high quality thumbnail for path: \(fullThumbnailPath)")
                ThumbnailProvider.highQualityImageCache.set(fullThumbnailPath, value: UIImage(contentsOfFile: fullThumbnailPath)!)
                shouldCacheHighQuality = false // Reset the trigger after caching
            } else {
                print("ThumbnailProvider: High-quality thumbnail already cached or not needed for path: \(fullThumbnailPath)")
            }
        } else {
            if ImageCache.shared.image(forKey: fullThumbnailPath) == nil, UIImage(contentsOfFile: fullThumbnailPath) == nil {
                if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                    print("ThumbnailProvider: Caching thumbnail for path: \(fullThumbnailPath)")
                    ImageCache.shared.set(image: uiImage, forKey: fullThumbnailPath)
                } else {
                    print("ThumbnailProvider: Failed to load UIImage for caching from path: \(fullThumbnailPath)")
                }
            } else {
                print("ThumbnailProvider: Thumbnail already cached or retrieved from file system for path: \(fullThumbnailPath)")
            }
        }
    }
}
