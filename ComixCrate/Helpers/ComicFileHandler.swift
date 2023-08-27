//
//  ComicFileHandler.swift
//  ComicFileLoader
//
//  Created by Ben Carney on 8/25/23.
//

import ZIPFoundation
import CoreData

class ComicFileHandler {
    
    static func handleImportedFile(at url: URL, in context: NSManagedObjectContext) {
        let fileManager = FileManager()
        let tempDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
        
        do {
            // Ensure directory exists
            if !fileManager.fileExists(atPath: tempDirectory.path) {
                try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            try fileManager.unzipItem(at: url, to: tempDirectory)
            
            let comicInfoURL = tempDirectory.appendingPathComponent("ComicInfo.xml")
            if fileManager.fileExists(atPath: comicInfoURL.path) {
                if let data = try? Data(contentsOf: comicInfoURL), let comicInfo = parseComicInfoXML(data: data) {
                    
                    let comicFile = ComicFile(context: context)
                    comicFile.fileName = url.lastPathComponent
                    comicFile.series = comicInfo.series
                    comicFile.publisher = comicInfo.publisher
                    comicFile.sypnosis = comicInfo.summary
                    comicFile.title = comicInfo.title
                    comicFile.issueNumber = comicInfo.number ?? 0
                    
                    /// Sorts the image files and picks the first one to be the cover thumbnail
                    if let imageFiles = try? fileManager.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).filter({ $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "png" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }), let firstImageName = imageFiles.first {
                        let destinationPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(UUID().uuidString).appendingPathExtension(firstImageName.pathExtension)
                        try fileManager.copyItem(at: firstImageName, to: destinationPath)
                        comicFile.thumbnailPath = destinationPath.path
                        // Save the Core Data context after setting up the comicFile
                        try context.save()
                    }

                    
                    try context.save()
                    print("Saved Comic File: \(comicFile)")  // Debug statement
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

    // ... other properties ...
}

// XMLParserDelegate to handle the parsing
class ComicInfoXMLParserDelegate: NSObject, XMLParserDelegate {
    var comicInfo = ComicInfo(series: "")
    var currentElement: String?
    var currentText = ""  // This will accumulate the characters for each element

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""  // Reset the accumulated text
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string  // Accumulate the characters
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch currentElement {
        case "Series":
            comicInfo.series = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Number":
            if let number = Int16(currentText.trimmingCharacters(in: .whitespacesAndNewlines)) {
                comicInfo.number = number
            }
        case "Web":
            comicInfo.web = URL(string: currentText.trimmingCharacters(in: .whitespacesAndNewlines))
        case "Summary":
            comicInfo.summary = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Publisher":
            comicInfo.publisher = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "Title":
            comicInfo.title = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        // ... handle other elements ...
        default:
            break
        }
        currentElement = nil  // Reset the current element
        currentText = ""  // Reset the accumulated text
    }

}

