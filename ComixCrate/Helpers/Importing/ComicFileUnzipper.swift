//
//  ComicFileUnzipper.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/2/23.
//

import Foundation
import ZIPFoundation

class ComicFileUnzipper {
    func unzipComicFile(at url: URL) throws -> URL {
        let unzipDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        
        guard let archive = Archive(url: url, accessMode: .read) else {
            throw NSError(domain: "UnzipError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read archive."])
        }
        
        for entry in archive {
            try archive.extract(entry, to: unzipDirectory)
        }
        
        return unzipDirectory
    }
}


