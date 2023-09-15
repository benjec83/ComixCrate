//
//  ComicDataWriter.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/2/23.
//

import CoreData
import UIKit

class ComicDataWriter {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func writeComicInfoToCoreData(_ comicInfo: ComicInfo, from url: URL) throws {
        let comicFile = Book(context: context)
        comicFile.fileName = url.lastPathComponent
        comicFile.filePath = url.path
        
        let fetchRequest: NSFetchRequest<Series> = Series.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", comicInfo.series ?? "")
        
        let seriesEntities = try? context.fetch(fetchRequest)
        var seriesEntity: Series!
        if let existingSeries = seriesEntities?.first {
            seriesEntity = existingSeries
        } else {
            seriesEntity = Series(context: context)
            seriesEntity.name = comicInfo.series
        }
        
        comicFile.series = seriesEntity
        
        let publisherFetchRequest: NSFetchRequest<Publisher> = Publisher.fetchRequest()
        publisherFetchRequest.predicate = NSPredicate(format: "name == %@", comicInfo.publisher ?? "")
        
        let publisherEntities = try? context.fetch(publisherFetchRequest)
        var publisherEntity: Publisher!
        if let existingPublisher = publisherEntities?.first {
            publisherEntity = existingPublisher
        } else {
            publisherEntity = Publisher(context: context)
            publisherEntity.name = comicInfo.publisher
        }
        
        comicFile.publisher = publisherEntity
        
        comicFile.summary = comicInfo.summary
        comicFile.title = comicInfo.title
        comicFile.issueNumber = comicInfo.number ?? 0
        comicFile.dateAdded = Date()
        
        if let imageFiles = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            
            for imageURL in imageFiles {
                if let originalImage = UIImage(contentsOfFile: imageURL.path),
                   let resizedImage = UIImage(data: originalImage.jpegData(compressionQuality: 1.0)!),
                   let imageData = resizedImage.jpegData(compressionQuality: 1) {
                    
                    var uniqueFilename = "\(UUID().uuidString).\(imageURL.pathExtension)"
                    var destinationPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(uniqueFilename)
                    
                    while FileManager.default.fileExists(atPath: destinationPath.path) {
                        print("File already exists. Generating a new UUID.")
                        uniqueFilename = "\(UUID().uuidString).\(imageURL.pathExtension)"
                        destinationPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(uniqueFilename)
                    }
                    
                    try? imageData.write(to: destinationPath)
                    
                    if comicFile.thumbnailPath == nil {
                        comicFile.thumbnailPath = uniqueFilename
                    }
                }
            }
            
            try context.save()
        }
    }
}
