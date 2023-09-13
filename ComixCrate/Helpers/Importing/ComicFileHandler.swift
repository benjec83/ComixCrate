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
    
    func isValidComicFile(at url: URL) -> Bool {
        let validExtensions = ["cbr", "cbz", "cbt", "cba"]
        
        // Check file extension
        let fileExtension = url.pathExtension.lowercased()
        if !validExtensions.contains(fileExtension) {
            return false
        }
        
        // Unzip and check if it contains images
        let fileManager = FileManager()
        let tempDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        
        do {
            try fileManager.unzipItem(at: url, to: tempDirectory)
            let imageFiles = try fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" })
            if imageFiles.isEmpty {
                return false
            }
        } catch {
            return false
        }
        
        return true
    }
    
    
    static func handleImportedFile(at url: URL, in context: NSManagedObjectContext) {
        let fileManager = FileManager()
        let tempDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        
        do {
            if !fileManager.fileExists(atPath: tempDirectory.path) {
                try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            try fileManager.unzipItem(at: url, to: tempDirectory)
            
            let comicInfoURL = tempDirectory.appendingPathComponent("ComicInfo.xml")
            if fileManager.fileExists(atPath: comicInfoURL.path) {
                if let data = try? Data(contentsOf: comicInfoURL), let comicInfo = parseComicInfoXML(data: data) {
                    
                    let comicFile = Book(context: context)
                    comicFile.fileName = url.lastPathComponent
                    comicFile.filePath = url.path
                    
                    // Add attribute values to Book Entity
                    
                    comicFile.sypnosis = comicInfo.summary
                    comicFile.title = comicInfo.title
                    comicFile.issueNumber = comicInfo.number ?? 0
                    comicFile.dateAdded = Date()
                    comicFile.web = comicInfo.web
                    
                    // Add Series to Series Entity
                    
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
                    
                    // Add Publisher to Publisher Entity
                    
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
                    }
                    
                    // MARK: Add Characters with Publisher (matched to Publisher Entity)
                    // Fetch all necessary entities first
                    var allCharactersEntities: [Characters] = []
                    for characterName in comicInfo.characters ?? [] {
                        let fetchRequest: NSFetchRequest<Characters> = Characters.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "characterName == %@", characterName)
                        if let charactersEntities = try? context.fetch(fetchRequest) {
                            allCharactersEntities.append(contentsOf: charactersEntities)
                        }
                    }
                    
                    // In a separate loop, make the necessary modifications
                    for characterName in comicInfo.characters ?? [] {
                        let publisherFetchRequest: NSFetchRequest<Publisher> = Publisher.fetchRequest()
                        publisherFetchRequest.predicate = NSPredicate(format: "name == %@", comicInfo.publisher ?? "")
                        if let publisherEntities = try? context.fetch(publisherFetchRequest), let publisherEntity = publisherEntities.first {
                            
                            let fetchRequest: NSFetchRequest<Characters> = Characters.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "characterName == %@ AND publisher == %@", characterName, publisherEntity)
                            let charactersEntities = try? context.fetch(fetchRequest)
                            var charactersEntity: Characters!
                            if let existingCharacter = charactersEntities?.first {
                                charactersEntity = existingCharacter
                            } else {
                                charactersEntity = Characters(context: context)
                                charactersEntity.characterName = characterName
                                charactersEntity.publisher = publisherEntity
                            }
                            
                            // Associate the character with the book
                            charactersEntity.addToBooks(comicFile)
                            
                            // Associate the book with the character
                            comicFile.addToCharacters(charactersEntity)
                        }
                    }
                    
                    // MARK: Add Teams with Publisher (matched to Publisher Entity)
                    // Fetch all necessary entities first
                    var allTeamsEntitites: [Teams] = []
                    for teamName in comicInfo.teams ?? [] {
                        let fetchRequest: NSFetchRequest<Teams> = Teams.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "teamName == %@", teamName)
                        if let teamsEntities = try? context.fetch(fetchRequest) {
                            allTeamsEntitites.append(contentsOf: teamsEntities)
                        }
                    }
                    
                    // In a separate loop, make the necessary modifications
                    for teamName in comicInfo.teams ?? [] {
                        let publisherFetchRequest: NSFetchRequest<Publisher> = Publisher.fetchRequest()
                        publisherFetchRequest.predicate = NSPredicate(format: "name == %@", comicInfo.publisher ?? "")
                        if let publisherEntities = try? context.fetch(publisherFetchRequest), let publisherEntity = publisherEntities.first {
                            
                            let fetchRequest: NSFetchRequest<Teams> = Teams.fetchRequest()
                            fetchRequest.predicate = NSPredicate(format: "teamName == %@ AND publisher == %@", teamName, publisherEntity)
                            let teamsEntities = try? context.fetch(fetchRequest)
                            var teamsEntity: Teams!
                            if let existingTeam = teamsEntities?.first {
                                teamsEntity = existingTeam
                            } else {
                                teamsEntity = Teams(context: context)
                                teamsEntity.teamName = teamName
                                teamsEntity.publisher = publisherEntity
                            }
                            
                            // Associate the team with the book
                            teamsEntity.addToBooks(comicFile)
                            
                            // Associate the book with the team
                            comicFile.addToTeams(teamsEntity)
                        }
                    }
                    

                    //
                    
                    if let imageFiles = try? fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
                        
                        for imageURL in imageFiles {
                            if let originalImage = UIImage(contentsOfFile: imageURL.path),
                               let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 180, height: 266)),
                               let imageData = resizedImage.jpegData(compressionQuality: 1) {
                                
                                let uniqueFilename = "\(UUID().uuidString).\(imageURL.pathExtension)"
                                let destinationPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(uniqueFilename)
                                
                                try? imageData.write(to: destinationPath)
                                
                                if comicFile.thumbnailPath == nil {
                                    comicFile.thumbnailPath = uniqueFilename
                                }
                                
                            }
                        }
                        
                        DispatchQueue.main.async {
                            try? context.save()
                        }
                    }
                    
                } else {
                    print("Failed to read or parse ComicInfo.xml")
                }
            } else {
                throw NSError(domain: "ComicFileHandlerError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "ComicInfo.xml does not exist at path: \(comicInfoURL.path)"])
                
            }
        } catch let error as ZIPFoundation.Archive.ArchiveError {
            print("ZIPFoundation error: \(error.localizedDescription)")
        } catch {
            print("Unknown error: \(error.localizedDescription)")
        }
        
        try? fileManager.removeItem(at: tempDirectory)
    }
    
    private static func parseComicInfoXML(data: Data) -> ComicInfo? {
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
        }
    }
}
