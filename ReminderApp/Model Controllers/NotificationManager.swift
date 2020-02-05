//
//  NotificationManager.swift
//  ReminderApp
//
//  Created by Michael Flowers on 2/5/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

struct NotificationManager {
    private static let notificationCenter = UNUserNotificationCenter.current()
    private static let locationManager = CLLocationManager()
    
    static func addLocationTrigger(forReminder reminder: Reminder, whenLeaving: Bool) -> UNLocationNotificationTrigger? {
        //unwrap reminder's location and identifier
        guard let location = reminder.locati
    }
}
