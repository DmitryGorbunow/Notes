//
//  CoreDataManager.swift
//  Notes
//
//  Created by Dmitry Gorbunow on 12/27/22.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager(modelName: "Notes")
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { (description, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("An error \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataManager {
    func createNote() -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.text = ""
        note.lastUpdated = Date()
        note.attributeString = NSAttributedString()
        save()
        return note
    }
    
    func fetchNotes(filter: String? = nil) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        if let filter = filter {
            let predicate = NSPredicate(format: "text contains[cd] %@", filter)
            request.predicate = predicate 
        }
        
        return (try? viewContext.fetch(request)) ?? []
    }
    
    func deleteNote(_ note: Note) {
        viewContext.delete(note)
        save()
    }
}
