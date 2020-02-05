//
//  LocationManager.swift
//  ReminderApp
//
//  Created by Michael Flowers on 2/5/20.
//  Copyright © 2020 Michael Flowers. All rights reserved.
//

import MapKit
import CoreLocation

//because we will use the locationManager in two or more files we should make a wrapper for it
struct LocationManager {
    static func searchLocation(with searchCompletion: MKLocalSearchCompletion, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let request = MKLocalSearch.Request(completion: searchCompletion)
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let error = error {
                print("Error in file: \(#file) in the body of the function: \(#function)\n on line: \(#line)\n Readable Error: \(error.localizedDescription)\n Technical Error: \(error)\n")
                completion(.failure(error))
            }  else if let response =  response {
                //the response has information that we want. We can grab the placeMark which has all the important information like country, state, city, and street address.
                if let placeMark = response.mapItems.first?.placemark {
                    completion(.success(placeMark.coordinate))
                }
            }
        }
        
    }
}
