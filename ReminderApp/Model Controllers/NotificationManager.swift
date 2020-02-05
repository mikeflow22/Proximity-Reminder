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
    
    //what information do we need to add a location trigger?
    static func addLocationTrigger(forReminder reminder: Reminder, whenLeaving: Bool) -> UNLocationNotificationTrigger? {
        //unwrap reminder's location and identifier
        guard let location = reminder.location, let identifier = reminder.identifier else { return nil }
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = CLCircularRegion(center: center, radius: reminder.radius, identifier: identifier.uuidString)
        
        //because we can only have one trigger on either exit or entrance switch on it
        switch whenLeaving {
        case true:
            region.notifyOnExit = true
            region.notifyOnEntry = false
        case false:
            region.notifyOnExit = false
            region.notifyOnEntry = true
        }
        
        //start monitoring the region
        locationManager.startMonitoring(for: region)
        
        return UNLocationNotificationTrigger(region: region, repeats: false)
    }
    
    //schedule the notification with the trigger
    static func scheduleNewNotification(withReminder reminder: Reminder, locationTrigger trigger: UNLocationNotificationTrigger?){
        if let text = reminder.note, let location = reminder.location, let identifier = location.identifier, let notificationTrigger = trigger {
            let content =  UNMutableNotificationContent()
            content.title = location.debugDescription
            content.body = text
            content.sound = .default
            let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
            notificationCenter.add(request) { (error) in
                if let error = error {
                    print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                    return
                }
            }
        }
    }
}
