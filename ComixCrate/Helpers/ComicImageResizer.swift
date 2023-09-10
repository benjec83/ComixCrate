//
//  ComicImageResizer.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/2/23.
//

import UIKit

class ComicImageResizer {
    func resizeImage(at url: URL, to size: CGSize) throws -> UIImage {
        guard let image = UIImage(contentsOfFile: url.path) else {
            throw NSError(domain: "ComicImageResizerError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Failed to load image from path: \(url.path)"])
        }
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
