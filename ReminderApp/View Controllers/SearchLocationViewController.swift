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
    let searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var currentLocation: CLLocation? {
        didSet {
            setRegion()
        }
    }
    var mapItems: [MKMapItem]?
    var annotations: [MKAnnotation]?
    
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
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchBar.text ?? ""
        //        print("query fragments: \(searchCompleter.queryFragment)")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchResults.removeAll()
        self.tableView.reloadData()
        print("annotations count 1 : \(self.annotations?.count)")
        if annotations == nil {
            self.annotations?.removeAll()
            self.mapView.removeAnnotations(annotations ?? [])
            
            print("annotations count 1 : \(self.annotations?.count)")
        } else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
        }
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
//        print("these are the search results count: \(self.searchResults.count)")
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
         
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
    
    //instead of using a segue we will use the didSelectRow delegate method to pass information to the detailVC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //segue using the storyboard ID
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as?  DetailReminderViewController else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return }
        
        //use the wrapper for the locationManager
        LocationManager.searchLocation(with: searchResults[indexPath.row]) { [weak self] (result) in
            guard let self = self else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return }
            guard let coordinate = try? result.get() else {
                print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
                return }
            detailVC.coordinate = coordinate
            
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("Error in file: \(#file), in the body of the function: \(#function) on line: \(#line)\n")
            return
        }
        
        self.currentLocation = location
        print("current location: \(String(describing: self.currentLocation))")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
         
    }
    
}
