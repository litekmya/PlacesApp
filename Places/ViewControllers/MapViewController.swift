//
//  MapViewController.swift
//  Places
//
//  Created by Владимир Ли on 24.05.2021.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImageView: UIImageView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    
    //MARK:- Public properties
    var place = Place()
    var segueIdentifier = ""
    var mapViewControllerDelegate: MapViewControllerDelegate?

    //MARK:- Private properties
    private let mapManager = MapManager()
    private let annotationIdentifier = "annotationIdentifier"
    private var previusLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                mapView: mapView, previusLocation: previusLocation) { currentlocation in
                previusLocation = currentlocation
            }
        }
    }
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentAddressLabel.text = ""
        goToAddress()
        
        mapView.delegate = self
    }
    
    //MARK:- Private Methods
    private func goToAddress() {
        navigationButton.isHidden = true
        mapManager.locationManager.delegate = self
        
        if segueIdentifier == "goToAddress" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            
            
            mapPinImageView.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            navigationButton.isHidden = false
        }
    }
    
    //MARK:- IBOutlets
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewInUserLocation(_ sender: Any) {
        mapManager.getUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        mapViewControllerDelegate?.getAddress(currentAddressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func navigationButtonPressed(_ sender: Any) {
        mapManager.getDirections(mapView: mapView) { currentLocation in
            previusLocation = currentLocation
        }
    }
}

    //MARK:- MKMapViewDelegate
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if segueIdentifier == "goToAddress" && previusLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.mapManager.getUserLocation(mapView: mapView)
            }
        }
        
        mapManager.getAddress(of: mapView, for: currentAddressLabel)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        
        return renderer
    }
}
    


    //MARK:- CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .restricted:
            mapManager.showAlert(title: mapManager.titleForAlert, message: mapManager.messageForAlert)
            break
        case .denied:
            mapManager.showAlert(title: mapManager.titleForAlert, message: mapManager.messageForAlert)
            break
        case .authorizedAlways:
            if segueIdentifier == "findAddress" {
                mapManager.getUserLocation(mapView: mapView)
            }
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            
            if segueIdentifier == "findAddress" {
                mapManager.getUserLocation(mapView: mapView)
            }
            break
        @unknown default:
            print("New case is available")
        }
    }
}
