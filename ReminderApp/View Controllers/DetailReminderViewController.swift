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
    var wantsNotificationWhenEntering = false
    
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
    
 
    
    //MARK: - IBActions
    @IBAction func EnterGeofenceButtonTapped(_ sender: UIButton) {
        //a quick indication that the button was selected
        enterGeofenceProperties.backgroundColor = .red
        wantsNotificationWhenEntering = true
    }
    
    @IBAction func exitGeofenceButtonTapped(_ sender: UIButton) {
        //a quick indication that the button was selected
        exitGeofenceProperties.backgroundColor = .blue
        wantsNotificationWhenEntering = false
    }
    
    @IBAction func setReminderButtonTapped(_ sender: UIButton) {
        guard let note = reminderTextField.text, !note.isEmpty, let coordinate = coordinate, let radiusString = radiusTextField.text, let radius = Double(radiusString) else { return }
        
        print(note)
        print(coordinate)
        print(radius)
        
        Reminder.new(note: note, wantsAlertOnEntrance: wantsNotificationWhenEntering, longitude: coordinate.longitude, latitude: coordinate.latitude, radius: radius) { result in
            if case .failure(let error) = result {
                print(error)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
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
