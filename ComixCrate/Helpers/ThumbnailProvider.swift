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

    var body: some View {
        thumbnailImage
            .onAppear(perform: cacheThumbnailImage)

    }

    private var thumbnailImage: some View {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if let cachedImage = ImageCache.shared.image(forKey: fullThumbnailPath) {
            return Image(uiImage: cachedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if FileManager.default.fileExists(atPath: fullThumbnailPath) {
            if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
                // Use the image from the path and cache it
                ImageCache.shared.set(image: uiImage, forKey: fullThumbnailPath)
                return Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                print("Failed to load UIImage from path: \(fullThumbnailPath)")
            }
        } else {
            print("File does not exist at path: \(fullThumbnailPath)")
        }
        // Use a placeholder image
        return Image("placeholderCover")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    private func cacheThumbnailImage() {
        let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullThumbnailPath = basePath.appendingPathComponent(book.thumbnailPath ?? "").path

        if let uiImage = UIImage(contentsOfFile: fullThumbnailPath) {
            ImageCache.shared.set(image: uiImage, forKey: fullThumbnailPath)
        }
    }
}

