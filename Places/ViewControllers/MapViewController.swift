//
//  MapViewController.swift
//  Places
//
//  Created by Владимир Ли on 24.05.2021.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK:- Public properties
    var place = Place()
    var segueIdentifier = ""

    //MARK:- Private properties
    private let mapManager = MapManager()
    private let annotationIdentifier = "annotationIdentifier"
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        goToAddress()
        
        mapView.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:- Private Methods
    private func goToAddress() {
        if segueIdentifier == "goToAddressSegue" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
        }
    }
    
    //MARK:- IBOutlets
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 10
            imageView.layer.borderWidth = 0.5
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(data: imageData)
            
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}
