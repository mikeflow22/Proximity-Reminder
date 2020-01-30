//
//  SearchLocationViewController.swift
//  ReminderApp
//
//  Created by Michael Flowers on 1/30/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SearchLocationViewController: UIViewController {
    
    //MARK: - Instance Properties
    let locationManager = CLLocationManager()
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var currentLocation: CLLocation? {
        didSet {
            setRegion()
        }
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchCompleter.delegate = self
        self.searchCompleter.region = self.mapView.region
        requestLocationPermission()
    }
    
    func requestLocationPermission(){
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse  {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func setRegion(){
        guard let userLocation = currentLocation else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        mapView.showsUserLocation = true
        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude
        
        let coordinate2d = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate2d, span: span)
        mapView.setRegion(region, animated: true)
//        mapView.setCenter(coordinate2d, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchCompleter.queryFragment = searchBar.text ?? ""
    }
}

//MARK: - UISearchBarDelegate Methods
extension SearchLocationViewController: UISearchBarDelegate {
    
}

//MARK: - MKMapViewDelegate Methods
extension SearchLocationViewController: MKMapViewDelegate {
    
}

//MARK: - MKLocalSearchCompleterDelegate Methods
extension SearchLocationViewController: MKLocalSearchCompleterDelegate {
    //As the user types, new completion suggestions are continuously returned to this method - overwrite the existing results, and then referesh the UI with the new results
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
        tableView.reloadData()
    }
}

//MARK: - UITableView Data Source and Delegate Methods
extension SearchLocationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        
        return cell
    }
}

//MARK: - CLLocationManagerDelegate Methods
extension SearchLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation() //this triggers a delegate callback
        case .restricted:
            print("restricted")
            locationManager.stopUpdatingLocation()
        case .notDetermined:
            print("not determined")
            locationManager.stopUpdatingLocation()
        case .denied:
            locationManager.stopUpdatingLocation()
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        
        self.currentLocation = location
        print("current location: \(self.currentLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
         
    }
    
}
