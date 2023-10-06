//
//  ImageUtilities.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/27/23.
//

import UIKit


// Image Cache
class ImageCache {
    private var cache = NSCache<NSString, UIImage>()

    static let shared = ImageCache()

    private init() {}

    func set(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        print("Caching image with key: \(key)")

    }

    func image(forKey key: String) -> UIImage? {
        if let _ = cache.object(forKey: key as NSString) {
            print("Retrieved image from cache with key: \(key)")
        } else {
            print("No image found in cache for key: \(key)")
        }

        return cache.object(forKey: key as NSString)
        
    }
}

// Image Resizing
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    
    
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    var newSize: CGSize
    print("Resizing image from \(size) to \(targetSize)")

    if widthRatio > heightRatio {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }
    
    

    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if let newImageSize = newImage?.size {
        print("Resized image to \(newImageSize)")
    } else {
        print("Failed to resize image")
    }

    return newImage
    
}

func imageFromPath(_ path: String) -> UIImage? {
    
    if let _ = UIImage(contentsOfFile: path) {
        print("Successfully created image from path: \(path)")
    } else {
        print("Failed to create image from path: \(path)")
    }

    return UIImage(contentsOfFile: path)
}

func imageFromCaches(forKey key: String, isHighQuality: Bool) -> UIImage? {
    if isHighQuality {
        if let _ = ThumbnailProvider.highQualityImageCache.get(key) {
            print("Retrieved high-quality image from cache with key: \(key)")
        } else {
            print("No high-quality image found in cache for key: \(key)")
        }

        return ThumbnailProvider.highQualityImageCache.get(key)
    } else {
        if let _ = ImageCache.shared.image(forKey: key) {
            print("Retrieved standard-quality image from cache with key: \(key)")
        } else {
            print("No standard-quality image found in cache for key: \(key)")
        }

        return ImageCache.shared.image(forKey: key)
    }
}


