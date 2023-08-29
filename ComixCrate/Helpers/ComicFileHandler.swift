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
    
    static func handleImportedFile(at url: URL, in context: NSManagedObjectContext) {
        let fileManager = FileManager()
        let tempDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium // This will include hours, minutes, and seconds
            return formatter
        }()

        
        do {
            // Ensure directory exists
            if !fileManager.fileExists(atPath: tempDirectory.path) {
                try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            try fileManager.unzipItem(at: url, to: tempDirectory)
            
            let comicInfoURL = tempDirectory.appendingPathComponent("ComicInfo.xml")
            if fileManager.fileExists(atPath: comicInfoURL.path) {
                if let data = try? Data(contentsOf: comicInfoURL), let comicInfo = parseComicInfoXML(data: data) {
                    
                    let comicFile = Book(context: context)
                    comicFile.fileName = url.lastPathComponent
                    
                    // Handling the Series relationship:
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
                    // End of the Series relationship handling.
                    
                    // Handling the Publisher relationship:
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
                    // End of the Publisher relationship handling.
                    
                    
                    comicFile.sypnosis = comicInfo.summary
                    comicFile.title = comicInfo.title
                    comicFile.issueNumber = comicInfo.number ?? 0
                    comicFile.volumeYear = comicInfo.year ?? 0
                    comicFile.dateAdded = Date()
                    
                    // Sorts the image files and picks the first one to be the cover thumbnail
                    if let imageFiles = try? fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }), let firstImageURL = imageFiles.first {
                        
                        if let originalImage = UIImage(contentsOfFile: firstImageURL.path),
                           let resizedImage = resizeImage(image: originalImage, targetSize: CGSize(width: 180, height: 266)),
                           let imageData = resizedImage.jpegData(compressionQuality: 1) {
                            
                            // Store the thumbnail in the app's document directory
                            let uniqueFilename = "\(UUID().uuidString).\(firstImageURL.pathExtension)"
                            let destinationPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(uniqueFilename)
                            
                            try? imageData.write(to: destinationPath)
                            comicFile.thumbnailPath = uniqueFilename // Only save the unique filename
                            print("Saving thumbnail to: \(destinationPath.path)")

                            // Check if the file exists at the saved path
                            if FileManager.default.fileExists(atPath: destinationPath.path) {
                                print("Thumbnail successfully saved at: \(destinationPath.path)")
                            } else {
                                print("Failed to save thumbnail at: \(destinationPath.path)")
                            }
                        }
                    }
                    
                    try context.save()
                    print("Saved Comic File: \(comicFile)")
                } else {
                    print("Failed to read or parse ComicInfo.xml")
                }
            } else {
                print("ComicInfo.xml does not exist at path: \(comicInfoURL.path)")
            }
        } catch let error as ZIPFoundation.Archive.ArchiveError {
            print("ZIPFoundation error: \(error.localizedDescription)")
        } catch {
            print("Unknown error: \(error.localizedDescription)")
        }
        
        // Cleanup temp directory
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
    var web: URL?
    var summary: String?
    var publisher: String?
    var title: String?
    var coverImageName: String?
    var year: Int16?
}

// XMLParserDelegate to handle the parsing
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
        case "Number": // Updated from "IssueNumber"
            if let number = Int16(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.number = number
            }
        case "Volume": // Updated from "VolumeYear"
            if let year = Int16(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.year = year
            }
        case "Web":
            comicInfo.web = URL(string: currentText.trimmingCharacters(in: .whitespacesAndNewlines))
        case "Summary":
            comicInfo.summary = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Publisher":
            comicInfo.publisher = currentText
        case .none, .some(_):
            // Handle the case where currentElement is nil or any other unexpected value.
            break
        }
    }
}
