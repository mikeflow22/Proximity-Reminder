//
//  Reminder+Convenience.swift
//  ReminderApp
//
//  Created by Michael Flowers on 1/30/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import CoreData

extension Reminder {
    
    static func fetchedResultsController() -> NSFetchedResultsController<Reminder> {
        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "note", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    static func new(note: String, wantsAlertOnEntrance: Bool, longitude: Double, latitude: Double, radius: Double, completion: @escaping (Result<Void, Error>) -> Void){
        let reminder = Reminder(context: CoreDataStack.shared.mainContext)
        let location = Location(context: CoreDataStack.shared.mainContext)
        location.identifier = UUID()
        location.latitude = latitude
        location.longitude = longitude
        reminder.identifier = UUID()
        reminder.note = note
        reminder.wantsAlertOnEntrance  = wantsAlertOnEntrance
        reminder.location  = location
        reminder.radius = radius
        
        do {
            try CoreDataStack.shared.mainContext.save()
            completion(.success(()))
        } catch  {
            print("Error in: \(#function)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)")
            completion(.failure(error))
        }
        
        let trigger = NotificationManager.addLocationTrigger(forReminder: reminder, whenLeaving: !wantsAlertOnEntrance)
        NotificationManager.scheduleNewNotification(withReminder: reminder, locationTrigger: trigger)
    }
    
}
