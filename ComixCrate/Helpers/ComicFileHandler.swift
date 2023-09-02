//
//  ComicFileHandler.swift
//  ComicFileLoader
//
//  Created by Ben Carney on 8/25/23.
//

//import ZIPFoundation
import CoreData
//import UIKit

class ComicFileHandler {
    let unzipper = ComicFileUnzipper()
    let parser = ComicXMLParser()
    let resizer = ComicImageResizer()
    let dataWriter: ComicDataWriter
    
    init(context: NSManagedObjectContext) {
        self.dataWriter = ComicDataWriter(context: context)
    }
    
    func handleImportedFile(at url: URL) throws {
        let unzippedURL = try unzipper.unzipComicFile(at: url)
        let comicInfo = try parser.parseComicInfo(from: unzippedURL)
        // Resize image logic using resizer
        try dataWriter.writeComicInfoToCoreData(comicInfo)
    }
}
