//
//  ComicDataWriter.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/2/23.
//

import CoreData

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
        fetchRequest.predicate = NSPredicate(format: "name == %@", comicInfo.series)
        
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
        
        comicFile.sypnosis = comicInfo.summary
        comicFile.title = comicInfo.title
        comicFile.issueNumber = comicInfo.number ?? 0
        comicFile.volumeYear = comicInfo.year ?? 0
        comicFile.dateAdded = Date()
        
        try context.save()
    }
}
