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
     var locationManager = CLLocationManager()
    var addressString: String? {
        didSet {
            print("addressString was hit")
            print("this is what was passed in: \(String(describing: addressString))")
            if let string = addressString {
                getAddressFrom(searchResultsTitle: string)
            }
        }
    }
    var coordinate: CLLocationCoordinate2D? {
        didSet {
            print("coordinate was set: \(coordinate.debugDescription)")
        }
    }
    
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
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
//        fakeData()
    }
    
    func fakeData(){
        let coordinate = CLLocationCoordinate2D(latitude: 36.01306251346607, longitude: -115.15559207182376)
        createLocalNotification(address: "FAKE DATA", body: "FAKE DATA", coordinate: coordinate, enterRegion: true, exitRegion: true, radius: 100)
        
    }
    
    //MARK: - IBActions
    @IBAction func EnterGeofenceButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func exitGeofenceButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func setReminderButtonTapped(_ sender: UIButton) {
      
//        guard let note = reminderTextField.text, !note.isEmpty, let radiusString = radiusTextField.text, !radiusString.isEmpty, let radiusDouble = Double(radiusString)  , let address = addressString, let coordinate = coordinate else {
//            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
//            return
//        }
//        if enterGeofenceProperties.isSelected == false && exitGeofenceProperties.isSelected == false {
//            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
//            return
//        }
        
        fakeData()
        
//        createLocalNotification(address: address, body: note, coordinate: coordinate, enterRegion: enterGeofenceProperties.isSelected, exitRegion: exitGeofenceProperties.isSelected, radius: radiusDouble)
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
    
//    func requestAuthorizationForNotifications(){
//
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
//            if let error = error {
//                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
//                return
//            }
//            if success {
//                UIApplication.shared.delegate = self
//                print("Success: \(success.description) in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
//
//            } else {
//                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
//                return
//            }
//        }
//    }
    
    func createLocalNotification(address: String, body: String, coordinate: CLLocationCoordinate2D, enterRegion: Bool, exitRegion: Bool, radius: Double){
        let notificationContent = UNMutableNotificationContent()
        //dress up notification
        notificationContent.title = "Reminder for location: \(address)"
        notificationContent.body = body
        notificationContent.sound = .default
        
        //CREATE the circular region to monitor and set if it should be triggered on entry  or exit or both
        let circularRegion = CLCircularRegion(center: coordinate, radius: radius, identifier: address)
        circularRegion.notifyOnEntry = enterRegion
        circularRegion.notifyOnExit = exitRegion
        
        //tell the location manager to start monitoring the region we've established
        locationManager.startMonitoring(for: circularRegion)
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
