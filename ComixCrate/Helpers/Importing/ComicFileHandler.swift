//
//  ComicFileHandler.swift
//  ComicFileLoader
//
//  Created by Ben Carney on 8/25/23.
//

import ZIPFoundation
import CoreData
import UIKit

class ComicFileHandler {
    
    static var failedImports: [String] = []
    
    
    // MARK: - File Handling
    
    // Check for valid file extension
    func hasValidFileExtension(_ url: URL) -> Bool {
        let validExtensions = ["cbr", "cbz", "cbt", "cba"]
        return validExtensions.contains(url.pathExtension.lowercased())
    }
    
    // Unzip file
    func unzipFile(at url: URL, to destination: URL) throws {
        let fileManager = FileManager()
        if !fileManager.fileExists(atPath: destination.path) {
            try fileManager.createDirectory(at: destination, withIntermediateDirectories: true, attributes: nil)
        }
        try fileManager.unzipItem(at: url, to: destination)
    }
    
    func isValidComicFile(at url: URL) -> Bool {
        // Check file extension
        if !hasValidFileExtension(url) {
            return false
        }
        
        // Unzip and check if it contains images
        let fileManager = FileManager()
        let tempDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        
        do {
            try unzipFile(at: url, to: tempDirectory)
            let imageFiles = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" })
            if imageFiles.isEmpty {
                print("Error: No image files found in the unzipped directory.")
                return false
            } else {
                print("Successfully found image files in the unzipped directory.")
            }
        } catch {
            print("Error: Failed to unzip or read the contents of the directory.")
            return false
        }
        return true
    }
    
    // MARK: - Entity Handling
    
    // Fetch entity
    func fetchEntity<T: NSManagedObject>(ofType type: T.Type, withPredicate predicate: NSPredicate, in context: NSManagedObjectContext) -> T? {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        return try? context.fetch(fetchRequest).first
    }
    
    // Fetch or create entity
    func fetchOrCreateEntity<T: NSManagedObject>(
        ofType type: T.Type,
        withName name: String,
        in context: NSManagedObjectContext,
        for key: String = "name"
    ) -> T {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = NSPredicate(format: "\(key) == %@", name)
        
        if let entity = try? context.fetch(fetchRequest).first {
            return entity
        } else {
            let newEntity = T(context: context)
            newEntity.setValue(name, forKey: key)
            return newEntity
        }
    }
    
    // Fetch or create entities in a loop with a publisher
    func fetchOrCreateEntities<T: NSManagedObject>(
        ofType type: T.Type,
        withNames names: [String],
        publisher: Publisher?,
        in context: NSManagedObjectContext,
        for key: String = "name",
        customizeEntity: ((T, Publisher?) -> Void)? = nil
    ) -> [T] {
        var entities: [T] = []
        
        for name in names {
            let entity = fetchOrCreateEntity(ofType: type, withName: name, in: context, for: key)
            
            // If a custom closure is provided, use it to customize the entity
            customizeEntity?(entity, publisher)
            
            entities.append(entity)
        }
        
        return entities
    }
    
    func fetchPublisher(withName name: String, in context: NSManagedObjectContext) -> [Publisher] {
        let publisherFetchRequest: NSFetchRequest<Publisher> = Publisher.fetchRequest()
        publisherFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            return try context.fetch(publisherFetchRequest)
        } catch {
            // Handle the error here, e.g., print or log it.
            return []
        }
    }
    
    static private let fileManager = FileManager()
    
    func handleImportedFile(at url: URL, in context: NSManagedObjectContext) throws {
        print("Starting to handle file: \(url.lastPathComponent)")
        
        let tempDirectory = ComicFileHandler.createTempDirectory()
        defer { ComicFileHandler.cleanupTempDirectory(tempDirectory) }
        
        try ComicFileHandler.unzipComicFile(at: url, to: tempDirectory)
        
        guard let comicInfo = ComicFileHandler.extractComicInfo(from: tempDirectory) else {
            throw ComicFileHandlerError.missingComicInfo
        }
        
        try saveComicInfo(comicInfo, from: url, in: context, tempDirectory: tempDirectory)
        
        // Remove the temporary directory
        try? ComicFileHandler.fileManager.removeItem(at: tempDirectory)
        
        if let error = handleImportError {
            throw error
        }
    }
    
    static private func createTempDirectory() -> URL {
        let tempDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        try? fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
        return tempDirectory
    }
    
    static private func cleanupTempDirectory(_ directory: URL) {
        try? fileManager.removeItem(at: directory)
    }
    
    static private func unzipComicFile(at url: URL, to destination: URL) throws {
        try fileManager.unzipItem(at: url, to: destination)
    }
    
    static private func extractComicInfo(from directory: URL) -> ComicInfo? {
        let comicInfoURL = directory.appendingPathComponent("ComicInfo.xml")
        guard let data = try? Data(contentsOf: comicInfoURL) else { return nil }
        return ComicFileHandler.parseComicInfoXML(data: data)
    }
    
    private func saveComicInfo(_ comicInfo: ComicInfo, from url: URL, in context: NSManagedObjectContext, tempDirectory: URL) throws {
        let comicFile = createComicFileEntity(from: comicInfo, url: url, in: context)
        associateEntities(with: comicFile, from: comicInfo, in: context)
        try saveImageFiles(from: tempDirectory, to: comicFile, in: context)
    }
    
    
    private func createComicFileEntity(from comicInfo: ComicInfo, url: URL, in context: NSManagedObjectContext) -> Book {
        let comicFile = Book(context: context)
        comicFile.fileName = url.lastPathComponent
        comicFile.filePath = url.path
        
        // Add attribute values to Book Entity
        comicFile.title = comicInfo.title
        comicFile.issueNumber = comicInfo.number ?? 0
        comicFile.dateAdded = Date()
        comicFile.summary = comicInfo.summary
        comicFile.web = comicInfo.web
        comicFile.volumeYear = comicInfo.volume ?? 0
        
        let comicFileHandler = ComicFileHandler()
        
        // Add Series to Series Entity
        comicFile.bookSeries = comicFileHandler.fetchOrCreateEntity(ofType: BookSeries.self, withName: comicInfo.series, in: context)
        
        // Add Publisher to Publisher Entity
        comicFile.publisher = comicFileHandler.fetchOrCreateEntity(ofType: Publisher.self, withName: comicInfo.publisher ?? "", in: context)
        
        // Fetch or create Publisher entity
        let publisherEntity = comicFileHandler.fetchOrCreateEntity(
            ofType: Publisher.self,
            withName: comicInfo.publisher ?? "",
            in: context
        )
        
        var allPublishers = comicFileHandler.fetchPublisher(withName: comicInfo.publisher ?? "", in: context)
        
        // Add Cover Date to Book.coverDate
        
        if let year = comicInfo.year, let month = comicInfo.month, let day = comicInfo.day {
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            
            let calendar = Calendar.current
            if let coverDate = calendar.date(from: dateComponents) {
                comicFile.coverDate = coverDate
            }
        }    }
    
    private func associateEntities(with comicFile: Book, from comicInfo: ComicInfo, in context: NSManagedObjectContext) {
        // MARK: Add Characters with Publisher (matched to Publisher Entity)
        let comicFileHandler = ComicFileHandler()
        // Fetch or create Characters entities with the associated publisher
        let charactersEntities = comicFileHandler.fetchOrCreateEntities(
            ofType: Characters.self,
            withNames: comicInfo.characters ?? [],
            publisher: publisherEntity,
            in: context
        ) { entity, publisher in
            if let charactersEntity = entity as? Characters {
                charactersEntity.publisher = publisher
            }
        }
        
        // Associate characters with the book
        charactersEntities.forEach { character in
            character.addToBooks(comicFile)
            comicFile.addToCharacters(character)
        }
        
        // MARK: Add Teams with Publisher (matched to Publisher Entity)
        // Fetch or create Teams entities with the associated publisher
        let teamsEntities = comicFileHandler.fetchOrCreateEntities(
            ofType: Teams.self,
            withNames: comicInfo.teams ?? [],
            publisher: publisherEntity,
            in: context
        ) { entity, publisher in
            if let teamsEntity = entity as? Teams {
                teamsEntity.publisher = publisher
            }
        }
        
        // Associate teams with the book
        teamsEntities.forEach { team in
            comicFile.addToTeams(team)
        }
        
        // MARK: Add Locations with Publisher (matched to Publisher Entity)
        // Fetch or create Locations entities with the associated publisher
        let locationsEntities = comicFileHandler.fetchOrCreateEntities(
            ofType: BookLocations.self,
            withNames: comicInfo.locations ?? [],
            publisher: publisherEntity,
            in: context
        ) { entity, publisher in
            if let locationsEntity = entity as? BookLocations {
                locationsEntity.publisher = publisher
            }
        }
        
        // Associate teams with the book
        locationsEntities.forEach { location in
            comicFile.addToLocations(location)
        }
        
        // MARK: Add CreatorRoles
        
        // Fetch or create CreatorRoles entities
        let creatorRolesEntities = comicFileHandler.fetchOrCreateEntities(
            ofType: CreatorRole.self,
            withNames: ["Writer", "Penciller", "Inker", "Colorist", "Letterer", "Cover Artist", "Editor"],
            publisher: publisherEntity,
            in: context
        )
        
        // Fetch or create Creators entities
        let creatorNames = [comicInfo.writer, comicInfo.penciller, comicInfo.inker, comicInfo.colorist, comicInfo.letterer, comicInfo.coverArtist, comicInfo.editor]
            .compactMap { $0 }
            .flatMap { $0 }
        
        let creatorsEntities = comicFileHandler.fetchOrCreateEntities(
            ofType: Creator.self,
            withNames: creatorNames,
            publisher: publisherEntity,
            in: context
        )
        
        // Associate creators with roles and the book
        for (roleName, creators) in [
            ("Writer", comicInfo.writer),
            ("Penciller", comicInfo.penciller),
            ("Inker", comicInfo.inker),
            ("Colorist", comicInfo.colorist),
            ("Letterer", comicInfo.letterer),
            ("Cover Artist", comicInfo.coverArtist),
            ("Editor", comicInfo.editor)
        ] {
            if let roleEntity = creatorRolesEntities.first(where: { $0.name == roleName }) {
                for creatorName in creators ?? [] {
                    if let creatorEntity = creatorsEntities.first(where: { $0.name == creatorName }) {
                        let bookCreatorRole = JoinEntityCreator(context: context)
                        bookCreatorRole.book = comicFile
                        bookCreatorRole.creator = creatorEntity
                        bookCreatorRole.creatorRole = roleEntity
                        comicFile.addToCreatorJoins(bookCreatorRole)
                    }
                }
            }
        }
    }
    
    private func saveImageFiles(from directory: URL, to comicFile: Book, in context: NSManagedObjectContext) throws {
        if let imageFiles = try? fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            print("Successfully fetched image files from the unzipped directory.")
            
            for imageURL in imageFiles {
                if let originalImage = UIImage(contentsOfFile: imageURL.path),
                   let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 180, height: 266)),
                   let imageData = resizedImage.jpegData(compressionQuality: 1) {
                    
                    let uniqueFilename = "\(UUID().uuidString).\(imageURL.pathExtension)"
                    let destinationPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(uniqueFilename)
                    
                    do {
                        try imageData.write(to: destinationPath)
                        print("Successfully saved image data to \(destinationPath).")
                    } catch {
                        print("Error saving thumbnail to path: \(destinationPath). Error: \(error.localizedDescription)")
                    }
                    
                    if comicFile.thumbnailPath == nil {
                        comicFile.thumbnailPath = uniqueFilename
                        print("Saved thumbnail with filename: \(uniqueFilename) for book: \(comicFile.title ?? "Unknown Title")")
                    }
                } else {
                    print("Error: Failed to process image at \(imageURL.path).")
                }
            }
            
            DispatchQueue.main.async {
                do {
                    try context.save()
                    print("Saved book details to CoreData for book: \(comicFile.title ?? "Unknown Title")")
                    context.reset()
                    print("\(url.lastPathComponent) imported successfully.")
                } catch let saveError {
                    print("Failed to save context: \(saveError)")
                }
            }
            
        } else {
            print("Error: Failed to fetch image files from the unzipped directory.")
        }
        
    }
    
    // MARK: - XML Parsing
    
    private func parseComicInfoXML(data: Data) -> ComicInfo? {
        let parser = XMLParser(data: data)
        let delegate = ComicInfoXMLParserDelegate()
        parser.delegate = delegate
        if parser.parse() {
            return delegate.comicInfo
        }
        return nil
    }
}

struct ComicInfo {
    var series: String
    var number: Int16?
    var web: String?
    var summary: String?
    var publisher: String?
    var title: String?
    var volume: Int16?
    var coverImageName: String?
    var year: Int?
    var month: Int?
    var day: Int?
    var writer: [String]?
    var penciller: [String]?
    var inker: [String]?
    var colorist: [String]?
    var letterer: [String]?
    var coverArtist: [String]?
    var editor: [String]?
    var characters: [String]?
    var teams: [String]?
    var locations: [String]?
}

class ComicInfoXMLParserDelegate: NSObject, XMLParserDelegate {
    var comicInfo = ComicInfo(series: "")
    var currentElement: String?
    var currentText = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch currentElement {
        case "Series":
            comicInfo.series = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Title":
            comicInfo.title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Number":
            if let number = Int16(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.number = number
            }
        case "Volume":
            if let volume = Int16(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.volume = volume
            }
        case "Year":
            if let year = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.year = year
            }
        case "Month":
            if let month = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.month = month
            }
        case "Day":
            if let day = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.day = day
            }
        case "Web":
            comicInfo.web = String(currentText.trimmingCharacters(in: .whitespacesAndNewlines))
        case "Summary":
            comicInfo.summary = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Publisher":
            comicInfo.publisher = currentText
        case "Writer":
            comicInfo.writer = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Penciller":
            comicInfo.penciller = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Inker":
            comicInfo.inker = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Colorist":
            comicInfo.colorist = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Letterer":
            comicInfo.letterer = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "CoverArtist":
            comicInfo.coverArtist = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Editor":
            comicInfo.editor = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Characters":
            comicInfo.characters = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Teams":
            comicInfo.teams = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case "Locations":
            comicInfo.locations = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
        case .none, .some(_):
            break
        default:
            break
        }
    }
}
