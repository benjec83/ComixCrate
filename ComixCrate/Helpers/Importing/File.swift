////
////  File.swift
////  ComixCrate
////
////  Created by Ben Carney on 9/14/23.
////
//
//import Foundation
//import CoreData
//import ZIPFoundation
//import UIKit
//
//class ComicFileHandler {
//    
//    let fileManager = FileManager.default
//    
//    func handleComicFile(at url: URL, in context: NSManagedObjectContext) throws {
//        let supportedExtensions = ["cbr", "cbz", "cbt", "cba"]
//        
//        guard supportedExtensions.contains(url.pathExtension.lowercased()) else {
//            throw ComicFileHandlerError.invalidFileExtension
//        }
//        
//        do {
//            let tempDirectory = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
//            try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
//            
//            // Unzip the file
//            guard let _ = try? fileManager.unzipItem(at: url, to: tempDirectory) else {
//                throw ComicFileHandlerError.unzipFailed
//            }
//            
//            // Parse the comic info
//            let comicInfoURL = tempDirectory.appendingPathComponent("ComicInfo.xml")
//            let comicInfoData = try Data(contentsOf: comicInfoURL)
//            let comicInfo = try XMLDecoder().decode(ComicInfo.self, from: comicInfoData)
//            
//            // Handle the comic info
//            let comicFile = Book(context: context)
//            comicFile.title = comicInfo.title
//            comicFile.summary = comicInfo.summary
//            
//            let publisherEntity = fetchOrCreatePublisher(withName: comicInfo.publisher, in: context)
//            comicFile.publisher = publisherEntity
//            
//            handleEntities(for: comicInfo.characters ?? [], in: context, with: comicFile, publisher: publisherEntity)
//            handleEntities(for: comicInfo.teams ?? [], in: context, with: comicFile, publisher: publisherEntity)
//            handleEntities(for: comicInfo.locations ?? [], in: context, with: comicFile, publisher: publisherEntity)
//            
//            // Handle creators and roles
//            handleCreatorsAndRoles(for: comicInfo, in: context, with: comicFile)
//            
//            handleImages(in: tempDirectory, for: comicFile)
//            
//            try context.save()
//            
//            try fileManager.removeItem(at: tempDirectory)
//            
//        } catch {
//            print("Error: \(error.localizedDescription)")
//            throw error
//        }
//    }
//    
//    func fetchOrCreatePublisher(withName name: String, in context: NSManagedObjectContext) -> Publisher {
//        let fetchRequest: NSFetchRequest<Publisher> = Publisher.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
//        
//        if let publisher = try? context.fetch(fetchRequest).first {
//            return publisher
//        } else {
//            let publisher = Publisher(context: context)
//            publisher.name = name
//            return publisher
//        }
//    }
//    
//    func handleEntities<T: NSManagedObject>(for names: [String], in context: NSManagedObjectContext, with comicFile: Book, publisher: Publisher) where T: HasName & HasBooks {
//        for name in names {
//            let entity = fetchOrCreateEntity(withName: name, in: context) as T
//            entity.addToBooks(comicFile)
//            comicFile.addToEntities(entity)
//        }
//    }
//    
//    func fetchOrCreateEntity<T: NSManagedObject>(withName name: String, in context: NSManagedObjectContext) -> T where T: HasName {
//        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
//        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
//        
//        if let entity = try? context.fetch(fetchRequest).first {
//            return entity
//        } else {
//            let entity = T(context: context)
//            entity.setValue(name, forKey: "name")
//            return entity
//        }
//    }
//    
//    func handleCreatorsAndRoles(for comicInfo: ComicInfo, in context: NSManagedObjectContext, with comicFile: Book) {
//        handleCreatorRoles(in: context)
//        handleCreators(for: comicInfo, in: context, with: comicFile)
//    }
//    
//    func handleCreatorRoles(in context: NSManagedObjectContext) {
//        let roleNames = ["Writer", "Penciller", "Inker", "Colorist", "Letterer", "Cover Artist", "Editor"]
//        
//        // Fetch all existing CreatorRoles
//        var existingRoles: [String: CreatorRole] = [:]
//        for roleName in roleNames {
//            let fetchRequest: NSFetchRequest<CreatorRole> = CreatorRole.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "name == %@", roleName)
//            if let roleEntities = try? context.fetch(fetchRequest) {
//                for entity in roleEntities {
//                    existingRoles[entity.name ?? ""] = entity
//                }
//            }
//        }
//        
//        // Create new roles if they don't exist
//        for roleName in roleNames {
//            if existingRoles[roleName] == nil {
//                let newRole = CreatorRole(context: context)
//                newRole.name = roleName
//            }
//        }
//    }
//    
//    func handleCreators(for comicInfo: ComicInfo, in context: NSManagedObjectContext, with comicFile: Book) {
//        var creators: [String] = []
//        if let writers = comicInfo.writer { creators.append(contentsOf: writers) }
//        // ... [Repeat for other roles]
//        
//        // Fetch all existing creators
//        var existingCreators: [String: Creator] = [:]
//        for creatorName in creators {
//            let fetchRequest: NSFetchRequest<Creator> = Creator.fetchRequest()
//            fetchRequest.predicate = NSPredicate(format: "name == %@", creatorName)
//            if let creatorEntities = try? context.fetch(fetchRequest) {
//                for entity in creatorEntities {
//                    existingCreators[entity.name ?? ""] = entity
//                }
//            }
//        }
//        
//        // Create new creators if they don't exist
//        for creatorName in creators {
//            if existingCreators[creatorName] == nil {
//                let newCreator = Creator(context: context)
//                newCreator.name = creatorName
//            }
//        }
//        
//        associateCreatorsWithRoles(for: comicInfo, in: context, with: comicFile)
//    }
//    
//    func associateCreatorsWithRoles(for comicInfo: ComicInfo, in context: NSManagedObjectContext, with comicFile: Book) {
//        let creatorRole: [String: [String]] = [
//            "Writer": comicInfo.writer ?? [],
//            "Penciller": comicInfo.penciller ?? [],
//            "Inker": comicInfo.inker ?? [],
//            "Colorist": comicInfo.colorist ?? [],
//            "Letterer": comicInfo.letterer ?? [],
//            "Cover Artist": comicInfo.coverArtist ?? [],
//            "Editor": comicInfo.editor ?? []
//        ]
//        
//        for (roleName, creators) in creatorRole {
//            let roleFetchRequest: NSFetchRequest<CreatorRole> = CreatorRole.fetchRequest()
//            roleFetchRequest.predicate = NSPredicate(format: "name == %@", roleName)
//            if let roleEntity = try? context.fetch(roleFetchRequest).first {
//                for creatorName in creators {
//                    let creatorFetchRequest: NSFetchRequest<Creator> = Creator.fetchRequest()
//                    creatorFetchRequest.predicate = NSPredicate(format: "name == %@", creatorName)
//                    if let creatorEntity = try? context.fetch(creatorFetchRequest).first {
//                        let bookCreatorRole = BookCreatorRole(context: context)
//                        bookCreatorRole.book = comicFile
//                        bookCreatorRole.creator = creatorEntity
//                        bookCreatorRole.creatorRole = roleEntity
//                        
//                        comicFile.addToBookCreatorRole(bookCreatorRole)
//                    }
//                }
//            }
//        }
//    }
//    
//    func handleImages(in tempDirectory: URL, for comicFile: Book) {
//        let imageDirectory = tempDirectory.appendingPathComponent("Images")
//        let imageFiles = try? fileManager.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil, options: [])
//        
//        for imageURL in imageFiles ?? [] {
//            let imageData = try? Data(contentsOf: imageURL)
//            let image = Image(context: comicFile.managedObjectContext!)
//            image.data = imageData
//            comicFile.addToImages(image)
//        }
//    }
//}
//
//extension ComicFileHandler {
//    struct ComicInfo {
//        var series: String
//        var number: Int16?
//        var web: String?
//        var summary: String?
//        var publisher: String?
//        var title: String?
//        var coverImageName: String?
//        var year: Int?
//        var month: Int?
//        var day: Int?
//        var writer: [String]?
//        var penciller: [String]?
//        var inker: [String]?
//        var colorist: [String]?
//        var letterer: [String]?
//        var coverArtist: [String]?
//        var editor: [String]?
//        var characters: [String]?
//        var teams: [String]?
//        var locations: [String]?
//    }
//    
//    class ComicInfoXMLParserDelegate: NSObject, XMLParserDelegate {
//        var comicInfo = ComicInfo(series: "")
//        var currentElement: String?
//        var currentText = ""
//        
//        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//            currentElement = elementName
//            currentText = ""
//        }
//        
//        func parser(_ parser: XMLParser, foundCharacters string: String) {
//            currentText += string
//        }
//        
//        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//            switch currentElement {
//            case "Series":
//                comicInfo.series = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
//            case "Title":
//                comicInfo.title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
//            case "Number":
//                if let number = Int16(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
//                    comicInfo.number = number
//                }
//            case "Volume":
//                if let year = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
//                    comicInfo.year = year
//                }
//            case "Month":
//                if let month = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
//                    comicInfo.month = month
//                }
//            case "Day":
//                if let day = Int(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
//                    comicInfo.day = day
//                }
//            case "Web":
//                comicInfo.web = String(currentText.trimmingCharacters(in: .whitespacesAndNewlines))
//            case "Summary":
//                comicInfo.summary = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
//            case "Publisher":
//                comicInfo.publisher = currentText
//            case "Writer":
//                comicInfo.writer = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Penciller":
//                comicInfo.penciller = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Inker":
//                comicInfo.inker = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Colorist":
//                comicInfo.colorist = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Letterer":
//                comicInfo.letterer = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "CoverArtist":
//                comicInfo.coverArtist = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Editor":
//                comicInfo.editor = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Characters":
//                comicInfo.characters = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Teams":
//                comicInfo.teams = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case "Locations":
//                comicInfo.locations = currentText.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ", ")
//            case .none, .some(_):
//                break
//            }
//        }
//    }
//}
