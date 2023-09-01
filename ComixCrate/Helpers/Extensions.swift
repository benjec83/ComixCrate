//
//  Extensions.swift
//  ComixCrate
//
//  Created by Ben Carney on 8/31/23.
//

import Foundation

/// Extensions to format the date for display.
extension Date {
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var formattedString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}
