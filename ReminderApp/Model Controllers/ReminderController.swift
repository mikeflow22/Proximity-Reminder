//
//  ReminderController.swift
//  ReminderApp
//
//  Created by Michael Flowers on 1/30/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import CoreData

//class ReminderController  {
//    static let shared = ReminderController()
//    var fetchedResultsController: NSFetchedResultsController<Reminder>
//    
//    init(){
//        //initialize an instance of fetchedResultsController and assign it to the variable
//        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
//        let sortDesriptors = [NSSortDescriptor(key: "radius", ascending: true), NSSortDescriptor(key: "wantsAlertOnEntrance", ascending: true)]
//        fetchRequest.sortDescriptors = sortDesriptors
//        let nsfr = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: "radius", cacheName: nil)
//        self.fetchedResultsController = nsfr
//        do {
//            try self.fetchedResultsController.performFetch()
//        } catch  {
//            print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
//        }
//    }
//    
//    //MARK: - CRUD FUNCTIONS
//    func createReminder(withNote note: String, wantsAlertOnEntrance: Bool, wantsAlertOnExit: Bool, longitude: Double, latitude: Double, radius: Double) -> Reminder {
//        let reminder = Reminder(note: note, wantsAlertOnEntrance: wantsAlertOnEntrance, wantsAlertOnExit: wantsAlertOnExit, longitude: longitude, latitude: latitude, radius: radius)
//        saveToPersistentStore()
//        return reminder
//    }
//    
//    func update(reminder: Reminder, with newNote: String, newRadius: Double, newExit: Bool, newEntrance: Bool){
//        reminder.note = newNote
//        reminder.radius = newRadius
//        reminder.wantsAlertOnEntrance = newEntrance
//        reminder.wantsAlertOnExit =  newExit
//        saveToPersistentStore()
//    }
//    
//    func delete(reminder: Reminder){
//        CoreDataStack.shared.mainContext.delete(reminder)
//        saveToPersistentStore()
//    }
//    
//    
//    func saveToPersistentStore(){
//        do {
//            try CoreDataStack.shared.mainContext.save()
//        } catch  {
//            print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
//        }
//    }
//    
//    
//    
//    
//    
//    
//    
//    
//}
