//
//  EditBookViewModel.swift
//  ComixCrate
//
//  Created by Ben Carney on 10/1/23.
//

import Foundation
import CoreData

class EditBookViewModel: ObservableObject {
    var moc: NSManagedObjectContext
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
}
