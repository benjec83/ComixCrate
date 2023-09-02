//
//  ComicXMLParser.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/2/23.
//

import Foundation

class ComicXMLParser {
    func parseComicInfo(from url: URL) throws -> ComicInfo {
        let data = try Data(contentsOf: url)
        let parser = XMLParser(data: data)
        let delegate = ComicInfoXMLParserDelegate()
        parser.delegate = delegate
        parser.parse()
        return delegate.comicInfo
    }
}

