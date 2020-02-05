//
//  DetailReminderViewController.swift
//  ReminderApp
//
//  Created by Michael Flowers on 1/30/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class DetailReminderViewController: UIViewController {
    
    //MARK: - INSTANCE PROPERTIES
    var entryButtonWasSelected: Bool = true
    var shouldShowExitButton: Bool = true
    var mylocationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    var wantsNotifictionWhenEntering = false
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var reminderTextField: UITextField!
    @IBOutlet weak var enterGeofenceProperties: UIButton!
    @IBOutlet weak var exitGeofenceProperties: UIButton!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var setReminderProperties: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resign)))
    }
    
    @objc func resign(){
        reminderTextField.resignFirstResponder()
        radiusTextField.resignFirstResponder()
    }
    
    //Start simulator on detailReminderViewController and just hit the set reminder button at the button. This is like mock data to see if the local notification works
    func fakeData(){
        let coordinate = CLLocationCoordinate2D(latitude: 36.01306251346607, longitude: -115.15559207182376)
        createFakeNotification(address: "FAKE DATA", body: "FAKE DATA", coordinate: coordinate, enterRegion: true, exitRegion: true, radius: 100)
    }
    
    //because  this notification is "fake" or "mock" I made it so that it doesn't take in a Reminder but it still takes in all of its properties.
    //i call this in the "fakeData()"
    
    func createFakeNotification(address: String, body: String,  coordinate:  CLLocationCoordinate2D, enterRegion: Bool, exitRegion: Bool, radius: Double){
        let notificationContent = UNMutableNotificationContent()
               //dress up notification
               notificationContent.title = "Reminder for location: \(address)"
               notificationContent.body = body
               notificationContent.sound = .default
               
               //CREATE the circular region to monitor and set if it should be triggered on entry  or exit or both
               let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
               let circularRegion = CLCircularRegion(center: coordinate, radius: radius, identifier: address)
               circularRegion.notifyOnEntry = enterRegion
               circularRegion.notifyOnExit = exitRegion
               
               //tell the location manager to start monitoring the region we've established
              mylocationManager.startMonitoring(for: circularRegion)
               print("Region locationManager will monitor: \(circularRegion.description)")
               
               //create the trigger
               let locationTrigger = UNLocationNotificationTrigger(region: circularRegion, repeats: false)
               
               //every local notification trigger needs a request
               let request = UNNotificationRequest(identifier: "Local trigger for: \(address)", content: notificationContent, trigger: locationTrigger)
               
               //add the request to the UNNotificationCenter singleton
               UNUserNotificationCenter.current().add(request) { (error) in
                   if let error = error {
                       print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                       return
                   } else {
                       print("WE SUCCEEDED SENDING THE LOCAITON TRIGGER")
                   }
               }
           }
    
    //This is actually the real notification function that takes in a Reminder object and then uses its properties to configure the notification and then adds the notification to the UNUserNotificationCenter
      func createLocalNotification(forReminder reminder: Reminder, withAddress address: String){
        //CREATE the circular region to monitor and set if it should be triggered on entry  or exit or both
        let coordinate = CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude)
        let circularRegion = CLCircularRegion(center: coordinate, radius: reminder.radius, identifier: address)
        circularRegion.notifyOnEntry = reminder.wantsAlertOnEntrance
        circularRegion.notifyOnExit = reminder.wantsAlertOnExit
        
        //tell the location manager to start monitoring the region we've established
        mylocationManager.startMonitoring(for: circularRegion)
        print("Region locationManager will monitor: \(circularRegion.description)")
        
            let notificationContent = UNMutableNotificationContent()
            //dress up notification
            notificationContent.title = "Reminder for location: \(address)"
            notificationContent.body = reminder.note ?? "n/a"
            notificationContent.sound = .default
            
            //create the trigger
            let locationTrigger = UNLocationNotificationTrigger(region: circularRegion, repeats: false)
            
            //every local notification trigger needs a request
            let request = UNNotificationRequest(identifier: "Local trigger for: \(address)", content: notificationContent, trigger: locationTrigger)
            
            //add the request to the UNNotificationCenter singleton
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                    return
                } else {
                    print("WE SUCCEEDED SENDING THE LOCAITON TRIGGER")
                }
            }
        }
    
    //MARK: - IBActions
    @IBAction func EnterGeofenceButtonTapped(_ sender: UIButton) {
        //a quick indication that the button was selected
        enterGeofenceProperties.backgroundColor = .red
    }
    
    @IBAction func exitGeofenceButtonTapped(_ sender: UIButton) {
        //a quick indication that the button was selected
        exitGeofenceProperties.backgroundColor = .blue

    }
    
    @IBAction func setReminderButtonTapped(_ sender: UIButton) {
        //calling the fake data function so that I don't have to manually type anything in on the other view controllers
//        fakeData()
        
        //printing values here to make sure that they arent empty before I unwrap them. Without doing this I wont know what exactly failed the guard statement below.
        print("NOte: \(reminderTextField.text)\n radius: \(radiusTextField.text)\n address: \(addressString)\n coordinates- lat: \(coordinate?.latitude)\n coordinate-long : \(coordinate?.longitude)")
        
        guard let note = reminderTextField.text, !note.isEmpty, let radiusString = radiusTextField.text, !radiusString.isEmpty, let radiusDouble = Double(radiusString), let address = addressString, let coordinate = coordinate else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        
        //just  making sure at least one of the buttons to monitor entrance or exit is selected
        if enterGeofenceProperties.isSelected == true || exitGeofenceProperties.isSelected == true {
            print("both buttons were selected")
        }

        //now that we are sure to have values in each of the views we can then construct an Reminder object
       let reminder = reminderController.createReminder(withNote: note, wantsAlertOnEntrance: enterGeofenceProperties.isSelected, wantsAlertOnExit: exitGeofenceProperties.isSelected, longitude: coordinate.longitude, latitude: coordinate.latitude, radius: radiusDouble)

        //now that we have a reminder object we can use that to create a local notification with a location trigger
        createLocalNotification(forReminder: reminder, withAddress: address)

        //visual indication that we made it this far 
        self.view.backgroundColor = .blue
    }
    
    
    //MARK: - Instance Methods
    
    func getAddressFrom(searchResultsTitle: String){
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchResultsTitle
        let localSearch = MKLocalSearch(request: request)
        
        localSearch.start { [unowned self] (response, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                return
            }
            if response == nil {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
            
            //get the lat and long associated with the string/word/name we just go back from this call
            guard let lat = response?.boundingRegion.center.latitude, let long = response?.boundingRegion.center.longitude else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
            
            //create annotation to add to map
            let annotation = MKPointAnnotation()
            annotation.title = searchResultsTitle
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            self.coordinate = coordinate
            annotation.coordinate = coordinate
            
            //add it to mapview
            self.mapView.addAnnotation(annotation)
            self.setSpan(with: coordinate)
        }
    }
    
    func setSpan(with coordinate: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
}
  

extension DetailReminderViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered region:  \(region.identifier)")
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region:  \(region.identifier)")
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return }
        print("this is the location: \(location.description)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
    }
}

extension DetailReminderViewController: MKMapViewDelegate {
    
}

extension DetailReminderViewController: UNUserNotificationCenterDelegate, UIApplicationDelegate {
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error: \(error)")
    }
}
