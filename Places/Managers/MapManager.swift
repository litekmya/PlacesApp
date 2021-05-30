//
//  MapManager.swift
//  Places
//
//  Created by Владимир Ли on 25.05.2021.
//

import UIKit
import MapKit

class MapManager {
    
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.address else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            guard let placemarkLocation = placemark?.location else { return }
            
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type
            annotation.coordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
}
