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
    
    func setSpan(with coordinate: CLLocationCoordinate2D){
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }
    
}

