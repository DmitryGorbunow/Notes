//
//  Note+CoreDataProperties.swift
//  Notes
//
//  Created by Dmitry Gorbunow on 12/28/22.
//
//

import Foundation
import CoreData

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID!
    @NSManaged public var lastUpdated: Date!
    @NSManaged public var text: String!
    @NSManaged public var attributeString: NSAttributedString?

}

extension Note : Identifiable {

}
