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
    @discardableResult
    convenience init(note: String, wantsAlertOnEntrance: Bool, wantsAlertOnExit: Bool, longitude: Double, latitude: Double, radius: Double, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.note = note
        self.wantsAlertOnEntrance = wantsAlertOnEntrance
        self.wantsAlertOnExit = wantsAlertOnExit
        self.longitude = longitude
        self.latitude = latitude
        self.radius = radius
    }
    
}
