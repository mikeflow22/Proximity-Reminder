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

    }
    
    //MARK: - IBActions
    @IBAction func EnterGeofenceButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func exitGeofenceButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func setReminderButtonTapped(_ sender: UIButton) {
        requestAuthorizationForNotifications()
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

    func requestAuthorizationForNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                return
            }
            if success {
                    print("Success: \(success.description) in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
              
            } else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DetailReminderViewController: MKMapViewDelegate {
    
}

extension DetailReminderViewController: UNUserNotificationCenterDelegate {
    
}
