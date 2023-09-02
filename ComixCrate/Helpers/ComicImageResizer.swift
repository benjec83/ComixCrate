//
//  ComicImageResizer.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/2/23.
//

import UIKit

class ComicImageResizer {
    func resizeImage(at url: URL, to size: CGSize) throws -> UIImage {
        let image = UIImage(contentsOfFile: url.path)!
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
