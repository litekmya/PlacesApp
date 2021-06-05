//
//  MapManager.swift
//  Places
//
//  Created by Владимир Ли on 25.05.2021.
//

import UIKit
import MapKit

class MapManager {
    //MARK:- Public properties
    let locationManager = CLLocationManager()
    let titleForAlert = "Location services are disabled"
    let messageForAlert = "To enable it go: Setting -> Privacy -> Location services and turn On"
    
    //MARK:- Private properties
    private var distanceInMeters = 500.0
    private var directionsArray: [MKDirections] = []
    private var placeLocation: CLLocationCoordinate2D?
    
    
    
    //MARK:- Public Methods
    // Создание метки по адресу
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
            
            self.placeLocation = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Получение адресса с помощью карты
    func getAddress(of mapView: MKMapView, for label: UILabel) {
        let center = getCenterLocation(mapView: mapView)
        
        let geocoder = CLGeocoder()
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(center) { placemarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            let streetName = placemark.thoroughfare
            let buildNumber = placemark.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    label.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    label.text = streetName!
                } else {
                    label.text = ""
                }
            }
        }
    }
    
    // Построение маршрута
    func getDirections(mapView: MKMapView, currentLocation: (CLLocation) ->()) {
        guard let userLocation = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation()
        
        currentLocation(CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude))
        
        guard
            let request = createDirectionRequest(placeLocation: placeLocation, coordinate: userLocation)
        else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        resetMapView(mapView: mapView, directions: directions)
        
        directions.calculate { response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distanse = route.distance
                let timeInterval = route.expectedTravelTime
            }
        }
    }
    
    // Начало отслеживания текущего местонахождения устройства
    func startTrackingUserLocation(mapView: MKMapView, previusLocation: CLLocation?, closure: (_ currentlocation: CLLocation) -> ()) {
        guard let previusLocation = previusLocation else { return }
        let center = getCenterLocation(mapView: mapView)
        guard center.distance(from: previusLocation) > 50 else { return }
        
        closure(center)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.getUserLocation(mapView: mapView)
        }
    }
    
    // Получение локации пользователя
    func getUserLocation(mapView: MKMapView) {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation,
                                            latitudinalMeters: distanceInMeters,
                                            longitudinalMeters: distanceInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    //MARK:- Private Methods
    // Создание запроса для построения маршрута
    private func createDirectionRequest(placeLocation: CLLocationCoordinate2D?, coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeLocation else { return nil }
        let startLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    // Получение центра текущей локации
    private func getCenterLocation(mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // Проверка сервисов местонахождения на устройстве
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: self.titleForAlert, message: self.messageForAlert)
            }
        }
    }
    
    // Удаление предыдущих маршрутов
    private func resetMapView(mapView: MKMapView, directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
}

//MARK:- AlertController
extension MapManager {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
    }
}
